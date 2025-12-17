class AddMinutesReloadedAtToTimeMaterials < ActiveRecord::Migration[8.1]
  def change
    add_column :time_materials, :minutes_reloaded_at, :datetime
  end
end
