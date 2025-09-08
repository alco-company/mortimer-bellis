require "test_helper"
require 'json'

class BackupTenantJobCompletenessTest < ActiveSupport::TestCase
  setup do
    @tenant = Tenant.first || Tenant.create!(name: 'T1')
    @user = @tenant.users.first || User.create!(email: "u-#{SecureRandom.hex(4)}@ex.com", password: 'secret', tenant: @tenant, team: Team.first || Team.create!(name: 'TeamX', tenant: @tenant))
  end

  test "backup includes all populated tenant-scoped tables" do
    # Seed minimal rows across a few key models (not all for speed) ensuring they have tenant_id
    c = Customer.create!(tenant: @tenant, name: 'CustA', country_key: 'DK', is_person: true)
    p = Project.create!(tenant: @tenant, name: 'ProjA', customer: c)
    Product.create!(tenant: @tenant, name: 'ProdA')
    Invoice.create!(tenant: @tenant, customer: c, invoice_number: 'INV1')

    job = BackupTenantJob.new
    archive = job.perform(tenant: @tenant, user: @user)
    assert archive, 'Archive path returned'

    # Read manifest
    label = File.basename(archive.to_s, '.tar.gz')
    extraction_dir = Rails.root.join('tmp', 'btj_test_' + SecureRandom.hex(4))
    FileUtils.mkdir_p(extraction_dir)
    system("tar -xzf #{archive} -C #{extraction_dir}")
    manifest_path = Dir.glob(extraction_dir.join(label, 'manifest.json').to_s).first
    metadata_path = Dir.glob(extraction_dir.join(label, 'metadata.json').to_s).first
    assert File.exist?(manifest_path), 'Manifest exists'
    assert File.exist?(metadata_path), 'Metadata exists'
    manifest = JSON.parse(File.read(manifest_path))

    tables_in_manifest = manifest.map { |m| m['table'] }
    %w[customers projects products invoices].each do |tbl|
      assert_includes tables_in_manifest, tbl, "#{tbl} present in manifest"
    end
  end
end
