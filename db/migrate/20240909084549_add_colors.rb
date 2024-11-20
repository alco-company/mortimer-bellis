class AddColors < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :employee_color, :string
    add_column :events, :event_color, :string
  end
end
