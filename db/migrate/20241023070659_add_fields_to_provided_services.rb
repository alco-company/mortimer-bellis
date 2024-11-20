class AddFieldsToProvidedServices < ActiveRecord::Migration[8.0]
  def change
    add_column :provided_services, :organizationID, :string
    add_column :provided_services, :account_for_one_off, :string
    add_column :provided_services, :product_for_time, :string
    add_column :provided_services, :product_for_overtime, :string
  end
end
