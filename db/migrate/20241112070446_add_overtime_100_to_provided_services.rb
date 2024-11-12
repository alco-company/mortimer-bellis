class AddOvertime100ToProvidedServices < ActiveRecord::Migration[8.0]
  def change
    add_column :provided_services, :product_for_overtime_100, :string
  end
end
