class AdditionalTwoFactorParameters < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :two_factor_app_enabled, :boolean, default: false, null: false
    add_column :users, :two_factor_app_enabled_at, :datetime
  end
end
