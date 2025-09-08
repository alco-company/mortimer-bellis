require "test_helper"
require 'json'

class BackupRestoreStrictTest < ActiveSupport::TestCase
  setup do
    @tenant = Tenant.first || Tenant.create!(name: 'T1')
    @user = @tenant.users.first || User.create!(email: "u-#{SecureRandom.hex(4)}@ex.com", password: 'secret', tenant: @tenant, team: Team.first || Team.create!(name: 'T', tenant: @tenant))
  end

  def full_purge(tenant)
    if defined?(DependencyGraph)
      DependencyGraph.purge_order.each do |m|
        begin
          k = m.constantize
          next unless k < ActiveRecord::Base && k.column_names.include?('tenant_id')
          k.unscoped.where(tenant_id: tenant.id).delete_all
        rescue
        end
      end
    end
  end

  def create_archive_with(models)
    label = "test_tenant_#{@tenant.id}_#{SecureRandom.hex(4)}"
    base_dir = Rails.root.join('tmp', label)
    FileUtils.mkdir_p(base_dir)
    dump_file = base_dir.join('dump.jsonl')
    File.open(dump_file, 'w') do |f|
      models.each do |(model, attrs)|
        f.puts({ model: model.to_s, data: attrs }.to_json)
      end
    end
    # minimal metadata with sha256
    require 'digest'
    sha = Digest::SHA256.file(dump_file).hexdigest
    metadata = { record_dump_sha256: sha, created_at: Time.now.utc.iso8601 }
    File.write(base_dir.join('metadata.json'), JSON.pretty_generate(metadata))
    archive = Rails.root.join('tmp', "#{label}.tar.gz")
    Dir.chdir(base_dir.dirname) do
      system("tar -czf #{archive} #{label}")
    end
    archive
  end

  test "strict restore aborts on missing parent" do
    full_purge(@tenant)
    inv_id = 500001
    archive = create_archive_with([
      [Invoice, { id: inv_id, tenant_id: @tenant.id, customer_id: 999999, invoice_number: 'INV-X', created_at: Time.now, updated_at: Time.now }]
    ])
    job = RestoreTenantJob.new
    e = assert_raises RuntimeError do
      job.perform(tenant: @tenant, user: @user, archive_path: archive.to_s, purge: true, restore: true, strict: true)
    end
    assert_match /Integrity failure missing parents/, e.message
  end

  test "consistent restore succeeds" do
    full_purge(@tenant)
    cust_id = 700001
    inv_id = 700010
    now = Time.now
    archive = create_archive_with([
      [Customer, { id: cust_id, tenant_id: @tenant.id, name: 'C', country_key: 'DK', is_person: true, created_at: now, updated_at: now }],
      [Invoice, { id: inv_id, tenant_id: @tenant.id, customer_id: cust_id, invoice_number: 'INV-OK', created_at: now, updated_at: now }]
    ])
    job = RestoreTenantJob.new
    summary = job.perform(tenant: @tenant, user: @user, archive_path: archive.to_s, purge: true, restore: true, strict: true)
    invoice_entry = summary.find { |e| e[:model] == 'Invoice' }
    assert invoice_entry, 'Invoice entry present'
    assert_equal 1, (invoice_entry[:inserted] || invoice_entry['inserted'])
  end

  test "collision remap rewrites child FKs" do
    full_purge(@tenant)
    other_tenant = Tenant.create!(name: 'Other') unless Tenant.where.not(id: @tenant.id).exists?
    other_tenant ||= Tenant.where.not(id: @tenant.id).first
    colliding_id = 910001
    Customer.unscoped.where(id: colliding_id).delete_all
    Customer.create!(id: colliding_id, tenant: other_tenant, name: 'OtherCust', country_key: 'DK', is_person: true)
    inv_id = colliding_id + 10
    now = Time.now
    archive = create_archive_with([
      [Customer, { id: colliding_id, tenant_id: @tenant.id, name: 'C', country_key: 'DK', is_person: true, created_at: now, updated_at: now }],
      [Invoice, { id: inv_id, tenant_id: @tenant.id, customer_id: colliding_id, invoice_number: 'INV-REMAPPED', created_at: now, updated_at: now }]
    ])
    job = RestoreTenantJob.new
    summary = job.perform(tenant: @tenant, user: @user, archive_path: archive.to_s, purge: true, restore: true, strict: true)
    remap_manifest = summary.find { |e| e[:id_remap_manifest] }&.dig(:id_remap_manifest)
    assert remap_manifest, 'Remap manifest present'
    new_customer_id = remap_manifest['Customer'][colliding_id.to_s]
    assert new_customer_id, 'Customer id remapped'
    invoice = Invoice.unscoped.find(inv_id)
    assert_equal new_customer_id, invoice.customer_id, 'Invoice customer_id rewritten to remapped id'
  end
end
