class AddUserToFilter < ActiveRecord::Migration[8.1]
  def change
    add_column :filters, :user_id, :integer, null: true
    add_column :filters, :state, :integer, default: 0
    add_column :filters, :name, :string
  end
end
