class UpdateUser2fa < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :otp_secret, :string
    remove_column :users, :encrypted_otp_secret, :string
    remove_column :users, :encrypted_otp_secret_iv, :string
    remove_column :users, :encrypted_otp_secret_salt, :string
  end
end
