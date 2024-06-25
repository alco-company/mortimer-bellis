class AddTaxIdToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :tax_number, :string
  end
end
