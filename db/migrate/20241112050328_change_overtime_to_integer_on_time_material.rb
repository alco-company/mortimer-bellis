class ChangeOvertimeToIntegerOnTimeMaterial < ActiveRecord::Migration[8.0]
  def self.up
    add_column :time_materials, :over_time, :integer
  end

  def self.down
    add_column :time_materials, :over_time, :boolean
  end
end
