class AddEvenMoreFieldsToTimeMaterial < ActiveRecord::Migration[8.0]
  def change
    add_column :time_materials, :odo_from, :integer
    add_column :time_materials, :odo_to, :integer
    add_column :time_materials, :kilometers, :integer
    add_column :time_materials, :trip_purpose, :string
    add_column :time_materials, :odo_from_time, :datetime
    add_column :time_materials, :odo_to_time, :datetime
  end
end
