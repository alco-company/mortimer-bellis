require "test_helper"
require "json"
require "digest"

class BackupTenantJobTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:one)
    @job = BackupTenantJob.new
    @work_dir = Rails.root.join("tmp", "test_backups")
    FileUtils.mkdir_p(@work_dir)
  end

  teardown do
    FileUtils.rm_rf(@work_dir) if Dir.exist?(@work_dir)
    # Clean up any archives created during tests
    Dir.glob(Rails.root.join("tmp", "tenant_#{@tenant.id}_*.tar.gz")).each { |f| File.delete(f) }
  end

  test "creates complete backup with all required files" do
    archive_path = @job.perform(tenant: @tenant)

    assert File.exist?(archive_path), "Archive should be created"
    assert archive_path.to_s.end_with?(".tar.gz"), "Should create compressed archive"

    # Extract and verify contents
    extract_dir = @work_dir.join("extracted")
    FileUtils.mkdir_p(extract_dir)
    system("tar -xzf #{archive_path} -C #{extract_dir}")

    backup_dir = Dir.children(extract_dir).first
    backup_path = extract_dir.join(backup_dir)

    # Verify required files exist
    assert File.exist?(backup_path.join("dump.jsonl")), "Should contain dump.jsonl"
    assert File.exist?(backup_path.join("file_ids.jsonl")), "Should contain file_ids.jsonl"
    assert File.exist?(backup_path.join("manifest.json")), "Should contain manifest.json"
    assert File.exist?(backup_path.join("metadata.json")), "Should contain metadata.json"
    assert File.exist?(backup_path.join("active_storage_attachments.jsonl")), "Should contain attachments"
    assert File.exist?(backup_path.join("active_storage_blobs.jsonl")), "Should contain blobs"
    assert Dir.exist?(backup_path.join("blobs")), "Should contain blobs directory"
  end

  test "backup contains all tenant records across all tables" do
    # Create test data across multiple models
    team = @tenant.teams.create!(name: "Test Team", color: "blue")
    user = @tenant.users.create!(email: "test@example.com", name: "Test User", team: team, password: "password123")

    archive_path = @job.perform(tenant: @tenant)
    extracted_data = extract_and_parse_backup(archive_path)

    # Verify tenant records are included
    tenant_records = extracted_data[:dump].select { |r| r["model"] == "tenants" }
    assert tenant_records.any? { |r| r["data"]["id"] == @tenant.id }, "Should backup tenant record"

    # Verify user records
    user_records = extracted_data[:dump].select { |r| r["model"] == "users" }
    assert user_records.any? { |r| r["data"]["tenant_id"] == @tenant.id }, "Should backup tenant users"

    # Verify file_ids contains all table->record mappings
    file_ids = extracted_data[:file_ids]
    DependencyGraph.backup_order.each do |table_name|
      next unless ActiveRecord::Base.connection.table_exists?(table_name)

      model = table_name.to_s.classify.constantize rescue next
      next unless model.column_names.include?("tenant_id")

      tenant_count = model.where(tenant_id: @tenant.id).count
      if tenant_count > 0
        assert file_ids.key?(table_name.to_s), "file_ids should include #{table_name}"
        assert_equal tenant_count, file_ids[table_name.to_s].size, "Should map all #{table_name} records"
      end
    end
  end

  test "backup excludes records from other tenants" do
    other_tenant = Tenant.create!(name: "Other Tenant", email: "other@example.com")
    other_team = other_tenant.teams.create!(name: "Other Team", color: "red")
    other_user = other_tenant.users.create!(email: "other@example.com", name: "Other User", team: other_team, password: "password123")

    archive_path = @job.perform(tenant: @tenant)
    extracted_data = extract_and_parse_backup(archive_path)

    # Ensure no records from other tenant
    extracted_data[:dump].each do |record|
      next unless record["data"].key?("tenant_id")
      assert_equal @tenant.id, record["data"]["tenant_id"],
        "Record #{record['model']}##{record['data']['id']} should belong to target tenant"
    end

    # Specifically check users
    user_records = extracted_data[:dump].select { |r| r["model"] == "users" }
    other_tenant_users = user_records.select { |r| r["data"]["tenant_id"] == other_tenant.id }
    assert_empty other_tenant_users, "Should not include other tenant's users"
  end

  test "backup handles active_storage attachments and blobs correctly" do
    skip unless defined?(ActiveStorage)

    # Create a user with an attachment
    team = @tenant.teams.create!(name: "Test Team", color: "blue")
    user = @tenant.users.create!(email: "test@example.com", name: "Test User", team: team, password: "password123")
    if user.respond_to?(:avatar) && user.avatar.respond_to?(:attach)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("test content"),
        filename: "test.txt",
        content_type: "text/plain"
      )
      user.avatar.attach(blob)
    end

    archive_path = @job.perform(tenant: @tenant)
    assert File.exist?(archive_path), "Backup should be created successfully"

    extracted_data = extract_and_parse_backup(archive_path)

    # Verify attachments are backed up
    if user.respond_to?(:avatar) && user.avatar.attached?
      attachments = extracted_data[:attachments]
      user_attachments = attachments.select { |a| a["record_id"] == user.id && a["record_type"] == "User" }
      assert user_attachments.any?, "Should backup user attachments"

      # Verify corresponding blob exists
      blob_ids = user_attachments.map { |a| a["blob_id"] }
      blobs = extracted_data[:blobs]
      backed_up_blobs = blobs.select { |b| blob_ids.include?(b["id"]) }
      assert_equal blob_ids.size, backed_up_blobs.size, "Should backup all referenced blobs"
    end
  end

  test "metadata file contains accurate backup information" do
    archive_path = @job.perform(tenant: @tenant)
    extracted_data = extract_and_parse_backup(archive_path)

    metadata = extracted_data[:metadata]

    # Verify metadata structure
    assert metadata["tenant_id"] == @tenant.id, "Should record correct tenant ID"
    assert metadata["created_at"], "Should record creation timestamp"
    assert metadata["schema_version"], "Should record schema version"
    assert metadata["record_dump_sha256"], "Should include dump checksum"

    # Verify dump checksum is accurate
    dump_content = File.read(extracted_data[:backup_dir].join("dump.jsonl"))
    actual_sha = Digest::SHA256.hexdigest(dump_content)
    assert_equal actual_sha, metadata["record_dump_sha256"], "Checksum should match actual dump content"

    # Verify manifest entry count matches actual manifest
    manifest = extracted_data[:manifest]
    assert_equal manifest.size, metadata["manifest_entries"], "Should record correct manifest size"
  end

  test "manifest accurately reflects backup contents" do
    # Count existing users for this tenant
    existing_user_count = @tenant.users.count

    # Create test data
    team = @tenant.teams.create!(name: "Test Team", color: "blue")
    @tenant.users.create!(email: "test1@example.com", name: "User 1", team: team, password: "password123")
    @tenant.users.create!(email: "test2@example.com", name: "User 2", team: team, password: "password123")

    expected_user_count = existing_user_count + 2

    archive_path = @job.perform(tenant: @tenant)
    extracted_data = extract_and_parse_backup(archive_path)

    manifest = extracted_data[:manifest]

    # Verify manifest entries
    users_manifest = manifest.find { |m| m["table"] == "users" }
    assert users_manifest, "Manifest should include users table"
    assert_equal expected_user_count, users_manifest["count"], "Should record correct user count"

    tenants_manifest = manifest.find { |m| m["table"] == "tenants" }
    assert tenants_manifest, "Manifest should include tenants table"
    assert_equal 1, tenants_manifest["count"], "Should record one tenant"
  end

  test "backup follows dependency order for referential integrity" do
    archive_path = @job.perform(tenant: @tenant)
    extracted_data = extract_and_parse_backup(archive_path)

    # Parse records in order they appear in dump
    models_in_order = []
    extracted_data[:dump].each do |record|
      model_name = record["model"]
      models_in_order << model_name unless models_in_order.include?(model_name)
    end

    dependency_order = DependencyGraph.backup_order.map(&:to_s)

    # Verify that dependencies appear before dependents
    # For example, tenants should come before users
    tenant_index = models_in_order.index("tenants")
    user_index = models_in_order.index("users")

    if tenant_index && user_index
      assert tenant_index < user_index, "Tenants should be backed up before users (dependency order)"
    end
  end

  test "handles empty tenant gracefully" do
    empty_tenant = Tenant.create!(name: "Empty Tenant", email: "empty@example.com")

    archive_path = @job.perform(tenant: empty_tenant)

    assert File.exist?(archive_path), "Should create archive even for empty tenant"

    extracted_data = extract_and_parse_backup(archive_path)

    # Should still have tenant record
    tenant_records = extracted_data[:dump].select { |r| r["model"] == "tenants" }
    assert tenant_records.any? { |r| r["data"]["id"] == empty_tenant.id }, "Should include the tenant itself"

    # Verify metadata is still valid
    metadata = extracted_data[:metadata]
    assert_equal empty_tenant.id, metadata["tenant_id"], "Metadata should reference correct tenant"
  end

  test "backup is restorable - smoke test" do
    # Create comprehensive test data
    team = @tenant.teams.create!(name: "Test Team", color: "blue")
    user = @tenant.users.create!(email: "restore_test@example.com", name: "Restore Test User", team: team, password: "password123")

    # Perform backup
    archive_path = @job.perform(tenant: @tenant)

    # Basic restoration verification - check that we can parse all backed up data
    extracted_data = extract_and_parse_backup(archive_path)

    # Verify we can reconstruct the data structure
    records_by_model = extracted_data[:dump].group_by { |r| r["model"] }

    records_by_model.each do |model_name, records|
      model_class = model_name.classify.constantize rescue next

      records.each do |record_data|
        attrs = record_data["data"]

        # Verify attributes are complete for model
        required_attrs = model_class.columns.reject(&:null).map(&:name)
        required_attrs.each do |attr|
          assert attrs.key?(attr),
            "Required attribute #{attr} missing from #{model_name} backup"
        end
      end
    end

    # Verify file_ids mapping is consistent
    file_ids = extracted_data[:file_ids]
    records_by_model.each do |model_name, records|
      table_name = model_name.tableize
      if file_ids[table_name]
        backed_up_ids = records.map { |r| r["data"]["id"] }
        assert_equal backed_up_ids.sort, file_ids[table_name].sort,
          "file_ids mapping should match actual backed up records for #{model_name}"
      end
    end
  end

  private

  def extract_and_parse_backup(archive_path)
    extract_dir = @work_dir.join("extracted_#{SecureRandom.hex(4)}")
    FileUtils.mkdir_p(extract_dir)

    system("tar -xzf #{archive_path} -C #{extract_dir}")
    backup_dir_name = Dir.children(extract_dir).first
    backup_dir = extract_dir.join(backup_dir_name)

    {
      backup_dir: backup_dir,
      dump: File.readlines(backup_dir.join("dump.jsonl")).map { |line| JSON.parse(line.strip) },
      file_ids: JSON.parse(File.read(backup_dir.join("file_ids.jsonl"))),
      manifest: JSON.parse(File.read(backup_dir.join("manifest.json"))),
      metadata: JSON.parse(File.read(backup_dir.join("metadata.json"))),
      attachments: File.exist?(backup_dir.join("active_storage_attachments.jsonl")) ?
        File.readlines(backup_dir.join("active_storage_attachments.jsonl")).map { |line| JSON.parse(line.strip) } : [],
      blobs: File.exist?(backup_dir.join("active_storage_blobs.jsonl")) ?
        File.readlines(backup_dir.join("active_storage_blobs.jsonl")).map { |line| JSON.parse(line.strip) } : []
    }
  end
end
