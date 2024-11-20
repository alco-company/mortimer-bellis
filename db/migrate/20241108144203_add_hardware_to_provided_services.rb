class AddHardwareToProvidedServices < ActiveRecord::Migration[8.0]
  def change
    add_column :provided_services, :product_for_hardware, :string
  end
end
