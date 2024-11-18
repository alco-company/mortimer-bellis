class AddFieldsToTimeMaterial < ActiveRecord::Migration[8.0]
  def change
    add_column :time_materials, :overtime, :boolean
    add_column :time_materials, :unit_price, :string
    add_column :time_materials, :unit, :string
  end
end
