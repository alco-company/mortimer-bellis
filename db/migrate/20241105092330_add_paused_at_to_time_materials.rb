class AddPausedAtToTimeMaterials < ActiveRecord::Migration[8.0]
  def change
    add_column :time_materials, :paused_at, :datetime
    add_column :time_materials, :started_at, :datetime
    add_column :time_materials, :time_spent, :integer
  end
end
