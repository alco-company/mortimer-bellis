class ChangeOvertimeColumn < ActiveRecord::Migration[8.1]
  def change
    change_column_default :time_materials, :over_time, from: nil, to: 0
    remove_column :time_materials, :overtime
  end
end
