class AddRegisteredMinutesToTimeMaterial < ActiveRecord::Migration[8.1]
  def up
    add_column :time_materials, :registered_minutes, :integer
    TimeMaterial.find_each do |time_material|
      unless time_material.time.blank?
        hours, minutes = time_material.time.split(":")
        time_material.update(registered_minutes: hours.to_i*60 + minutes.to_i)
      end
    end
  end
  def down
    remove_column :time_materials, :registered_minutes
  end
end
