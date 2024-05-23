class AddColorToAccount < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :account_color, :string
  end
end
