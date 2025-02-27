class SetPasswordDigestType < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :users, :password_digest, :string
        change_column :users, :otp_secret_key, :string
        change_column :users, :otp_enabled, :boolean, default: false
        change_column :users, :otp_enabled_at, :datetime
        change_column :users, :invitations_limit, :integer
      end

      dir.down do
        change_column :users, :password_digest, :string
        change_column :users, :otp_secret_key, :string
        change_column :users, :otp_enabled, :boolean, default: false
        change_column :users, :otp_enabled_at, :datetime
        change_column :users, :invitations_limit, :integer
      end
    end
  end
end
