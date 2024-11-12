class ChangeOvertimeToIntegerOnTimeMaterial < ActiveRecord::Migration[8.0]
  def self.up
    add_column :time_materials, :over_time, :integer

    # backfill the column with the correct data
    execute "UPDATE time_materials SET over_time = 0 WHERE overtime = false"
    execute "UPDATE time_materials SET over_time = 2 WHERE overtime = true"

    # apply appropriate constraints and defaults once it's backfilled
    change_column_default :time_materials, :over_time, 0
    # change_column_null :time_materials, :over_time, false

    # swap the new column in place of the old column
    rename_column :time_materials, :overtime, :old_overtime
    rename_column :time_materials, :over_time, :overtime

    # once you've verified that everything is correct, drop the old column
    remove_column :time_materials, :old_overtime
  end

  def self.down
    add_column :time_materials, :over_time, :boolean

    # backfill the column with the correct data
    execute "UPDATE time_materials SET over_time = false WHERE overtime = 0"
    execute "UPDATE time_materials SET over_time = true WHERE overtime > 0"

    # apply appropriate constraints and defaults once it's backfilled
    change_column_default :time_materials, :over_time, :false
    # change_column_null :time_materials, :over_time, false

    # swap the new column in place of the old column
    rename_column :time_materials, :overtime, :old_overtime
    rename_column :time_materials, :over_time, :overtime

    # once you've verified that everything is correct, drop the old column
    remove_column :time_materials, :old_overtime
  end
end
