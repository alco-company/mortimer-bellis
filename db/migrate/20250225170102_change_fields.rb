class ChangeFields < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :encrypted_password, :password_digest

    rename_column :users, :otp_secret, :otp_secret_key

    rename_column :users, :invitation_limit, :invitations_limit
  end
end
