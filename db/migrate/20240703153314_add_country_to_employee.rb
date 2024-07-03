class AddCountryToEmployee < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :country, :string
    add_column :accounts, :country, :string
    add_column :teams, :country, :string
  end
end
