class BackupTenantJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    tenant = @tenant
    return unless tenant

    summary = []
    log_progress(summary, step: :start)

    Rails.application.eager_load! unless Rails.application.config.eager_load

    # Setup working directory and backup files
    timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
    label = "tenant_#{tenant.id}_#{timestamp}"
    # Use storage directory instead of tmp - tmp is not persisted in Docker volumes
    base_dir = Rails.root.join("storage", "tenant_backups", label)
    FileUtils.mkdir_p(base_dir)

    manifest = []
    summary << ({ timestamp: timestamp, label: label, base_dir: base_dir })
    log_progress(summary, step: :scan_tables)

    # - part of Rails
    models_by_table = {}
    ActiveRecord::Base.descendants.each do |m|
      next unless m.respond_to?(:table_name)
      models_by_table[m.table_name] = m
    end

    tenant_tables = DependencyGraph.backup_order
    raise "No tenant tables found" if tenant_tables.empty?

    dump_path = base_dir.join("dump.jsonl")
    file_ids_path = base_dir.join("file_ids.jsonl")
    attachments_path = base_dir.join("active_storage_attachments.jsonl")
    blobs_path       = base_dir.join("active_storage_blobs.jsonl")
    storage_root     = base_dir.join("blobs")
    seen_blob_ids = Set.new
    FileUtils.mkdir_p(storage_root)

    summary << ({ dump_path: dump_path, attachments_path: attachments_path, blobs_path: blobs_path, storage_root: storage_root })
    log_progress(summary, step: :paths_created)

    processed = 0
    table_ids = {}
    File.open(dump_path, "w") do |f|
      File.open(attachments_path, "w") do |fa|
        File.open(blobs_path, "w") do |fb|
          tenant_tables.each do |table|
            begin
              model = models_by_table[table]
              count, table_ids[table], result = model.backup(f: f, fa: fa, fb: fb, seen_blob_ids: seen_blob_ids, storage_root: storage_root, tenant_id: tenant.id) if model
              next if count == 0
              processed += count
              manifest << ({ table: table, model: table.to_s, count: count })
              log_progress(summary, step: :dump_progress, table: table, processed: processed, result: result)

            rescue => e
              manifest << { table: table, model: (model&.name), error: e.message }
              log_progress(summary, step: :error, table: table, message: e.message)
            end
          end
        end
      end
    end

    File.write(file_ids_path, JSON.pretty_generate(table_ids))
    log_progress(summary, step: :file_ids_written)

    File.write(base_dir.join("manifest.json"), JSON.pretty_generate(manifest))
    log_progress(summary, step: :manifest_written, entries: manifest.size)

    begin
      require "digest"
      dump_file = base_dir.join("dump.jsonl")
      dump_sha256 = File.exist?(dump_file) ? Digest::SHA256.file(dump_file).hexdigest : nil
      attachments_count = 0
      attach_list_file = base_dir.join("active_storage_attachments.jsonl")
      attachments_count = File.foreach(attach_list_file).count rescue 0 if File.exist?(attach_list_file)
      git_sha = `git rev-parse HEAD`.strip rescue nil
      metadata = {
        schema_version: (ActiveRecord::Migrator.current_version rescue nil),
        app_sha: git_sha,
        created_at: Time.now.utc.iso8601,
        tenant_id: tenant.id,
        manifest_entries: manifest.size,
        record_dump_sha256: dump_sha256,
        active_storage_attachments_count: attachments_count
      }
      File.write(base_dir.join("metadata.json"), JSON.pretty_generate(metadata))
      summary << ({ dump_file: dump_file, dump_sha256: dump_sha256, attachments_count: attachments_count, git_sha: git_sha })
      log_progress(summary, step: :metadata_written)
    rescue => e
      log_progress(summary, step: :metadata_error, message: e.message)
    end

    archive_path = Rails.root.join("storage", "tenant_backups", "#{label}.tar.gz").to_s
    begin
      Dir.chdir(base_dir.dirname)
      success = system("tar -czf #{archive_path} #{label}")
      unless success
        raise "tar command failed with exit code #{$?.exitstatus}"
      end
    ensure
      Dir.chdir(Rails.root)
    end
    log_progress(summary, step: :archive_created, path: archive_path)

    begin
      # Generate a proper download URL instead of file path
      filename = File.basename(archive_path)
      download_url = Rails.application.routes.url_helpers.tenant_backup_download_url(filename: filename, host: ENV["WEB_HOST"] || "localhost:3000", protocol: "https")
      TenantMailer.with(tenant: tenant, link: download_url).backup_created.deliver_later
      log_progress(summary, step: :email_enqueued, download_url: download_url)

      # Cleanup: Remove temporary directory after successful archive creation and email queuing
      FileUtils.rm_rf(base_dir)
      log_progress(summary, step: :cleanup_completed, removed: base_dir.to_s)
    rescue => e
      say "BackupTenantJob email failed: #{e.message}"
      log_progress(summary, step: :error, phase: :email, message: e.message)
    end

    archive_path
  rescue => e
    say "BackupTenantJob failed: #{e.message}"
    log_progress(summary, step: :failed, message: e.message)
    UserMailer.error_report(e.full_message, "BackupTenantJob#perform").deliver_later rescue nil
  end
end
