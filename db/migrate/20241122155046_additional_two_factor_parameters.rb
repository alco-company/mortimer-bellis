class AdditionalTwoFactorParameters < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :otp_enabled, :boolean, default: false, null: false
    add_column :users, :otp_enabled_at, :datetime
  end
end
