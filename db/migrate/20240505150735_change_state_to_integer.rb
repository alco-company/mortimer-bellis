class ChangeStateToInteger < ActiveRecord::Migration[7.2]
  def change
    change_column :employees, :state, :integer, default: 0
    change_column :teams, :state, :integer, default: 0
    change_column :punches, :state, :integer, default: 0
  end
end
