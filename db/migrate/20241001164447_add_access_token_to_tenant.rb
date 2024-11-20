class AddAccessTokenToTenant < ActiveRecord::Migration[8.0]
  def change
    add_column :tenants, :access_token, :string
  end
end
