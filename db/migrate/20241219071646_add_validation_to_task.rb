class AddValidationToTask < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :validation, :text
  end
end
