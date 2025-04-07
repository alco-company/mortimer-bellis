class AddLicenseToTenant < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :license, :integer, default: 0
    add_column :tenants, :license_expires_at, :datetime
    add_column :tenants, :license_changed_at, :datetime
  end
end
