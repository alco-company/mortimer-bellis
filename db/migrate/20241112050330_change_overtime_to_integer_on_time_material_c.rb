class ChangeOvertimeToIntegerOnTimeMaterialC < ActiveRecord::Migration[8.0]
  def self.up
    # once you've verified that everything is correct, drop the old column
    remove_column :time_materials, :old_overtime
  end

  def self.down
    # once you've verified that everything is correct, drop the old column
    remove_column :time_materials, :old_overtime
  end
end
