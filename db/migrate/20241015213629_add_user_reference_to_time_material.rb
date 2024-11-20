class AddUserReferenceToTimeMaterial < ActiveRecord::Migration[8.0]
  def change
    TimeMaterial.delete_all
    add_reference :time_materials, :user, null: false, foreign_key: true
  end
end
