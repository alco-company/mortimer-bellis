class AddLockVersionToTimeMaterial < ActiveRecord::Migration[8.1]
  def change
    add_column :time_materials, :lock_version, :integer
  end
end
