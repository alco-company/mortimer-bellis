class AddCustomerAndProjectToTasks < ActiveRecord::Migration[8.2]
  def change
    add_reference :tasks, :customer, null: true, foreign_key: true
    add_reference :tasks, :project, null: true, foreign_key: true
  end
end
