require "test_helper"
require 'json'

class RestoreCollisionExtendedTest < ActiveSupport::TestCase
  setup do
    @tenant = Tenant.first || Tenant.create!(name: 'T1')
    @user = @tenant.users.first || User.create!(email: "u-#{SecureRandom.hex(4)}@ex.com", password: 'secret', tenant: @tenant, team: Team.first || Team.create!(name: 'T', tenant: @tenant))
  end

  def create_archive(models)
    label = "test_ext_#{@tenant.id}_#{SecureRandom.hex(4)}"
    base_dir = Rails.root.join('tmp', label)
    FileUtils.mkdir_p(base_dir)
    File.open(base_dir.join('dump.jsonl'),'w') do |f|
      models.each { |(model, attrs)| f.puts({ model: model.to_s, data: attrs }.to_json) }
    end
    archive = Rails.root.join('tmp', "#{label}.tar.gz")
    Dir.chdir(base_dir.dirname) { system("tar -czf #{archive} #{label}") }
    archive
  end

  test "multi-level collision remaps propagate to grandchildren" do
    other = Tenant.where.not(id: @tenant.id).first || Tenant.create!(name: 'Other')
    # Build chain Customer -> Project -> Invoice
    base_id = 8800001
    Customer.unscoped.where(id: base_id).delete_all
    Project.unscoped.where(id: base_id+1).delete_all
    Invoice.unscoped.where(id: base_id+2).delete_all
    # Create conflicting Customer id in other tenant
    Customer.create!(id: base_id, tenant: other, name: 'OtherCust', country_key: 'DK', is_person: true)
    now = Time.now
    archive = create_archive([
      [Customer, { id: base_id, tenant_id: @tenant.id, name: 'CustA', country_key: 'DK', is_person: true, created_at: now, updated_at: now }],
      [Project, { id: base_id+1, tenant_id: @tenant.id, name: 'ProjA', customer_id: base_id, created_at: now, updated_at: now }],
      [Invoice, { id: base_id+2, tenant_id: @tenant.id, customer_id: base_id, project_id: base_id+1, invoice_number: 'INV-CHAIN', created_at: now, updated_at: now }]
    ])
    summary = RestoreTenantJob.new.perform(tenant: @tenant, user: @user, archive_path: archive.to_s, purge: true, restore: true, strict: true)
    remap = summary.find { |e| e[:id_remap_manifest] }&.dig(:id_remap_manifest) || {}
    new_cust_id = remap.dig('Customer', base_id.to_s)
    assert new_cust_id, 'Customer id remapped'
    proj = Project.unscoped.find(base_id+1)
    inv = Invoice.unscoped.find(base_id+2)
    assert_equal new_cust_id, proj.customer_id, 'Project customer FK remapped'
    assert_equal new_cust_id, inv.customer_id, 'Invoice customer FK remapped'
  end

  test "collision without remap feature flag raises" do
    other = Tenant.where.not(id: @tenant.id).first || Tenant.create!(name: 'Other2')
    colliding_id = 9901001
    Customer.unscoped.where(id: colliding_id).delete_all
    Customer.create!(id: colliding_id, tenant: other, name: 'OtherCustX', country_key: 'DK', is_person: true)
    now = Time.now
    archive = create_archive([
      [Customer, { id: colliding_id, tenant_id: @tenant.id, name: 'CustFlag', country_key: 'DK', is_person: true, created_at: now, updated_at: now }]
    ])
    ENV['RESTORE_NO_REMAP'] = '1'
    assert_raises RuntimeError do
      RestoreTenantJob.new.perform(tenant: @tenant, user: @user, archive_path: archive.to_s, purge: true, restore: true, strict: true)
    end
  ensure
    ENV.delete('RESTORE_NO_REMAP')
  end
end
