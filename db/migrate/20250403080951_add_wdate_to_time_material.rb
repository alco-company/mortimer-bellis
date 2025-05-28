class AddWdateToTimeMaterial < ActiveRecord::Migration[8.1]
  def change
    add_column :time_materials, :wdate, :date
  end
end
