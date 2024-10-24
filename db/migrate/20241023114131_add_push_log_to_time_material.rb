class AddPushLogToTimeMaterial < ActiveRecord::Migration[8.0]
  def change
    add_column :time_materials, :push_log, :text
  end
end
