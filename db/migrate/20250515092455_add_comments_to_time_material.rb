class AddCommentsToTimeMaterial < ActiveRecord::Migration[8.1]
  def change
    add_column :time_materials, :task_comment, :text
    add_column :time_materials, :location_comment, :text
  end
end
