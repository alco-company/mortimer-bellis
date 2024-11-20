class AddMoreFieldsToTimeMaterial < ActiveRecord::Migration[8.0]
  def change
    add_column :time_materials, :pushed_erp_timestamp, :string
    add_column :time_materials, :erp_guid, :string
  end
end
