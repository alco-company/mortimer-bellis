class AddCommentToTimeMaterial < ActiveRecord::Migration[8.0]
  def change
    add_column :time_materials, :comment, :text
    rename_column :time_materials, :product_, :product_name
  end
end
