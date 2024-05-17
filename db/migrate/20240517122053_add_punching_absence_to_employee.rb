class AddPunchingAbsenceToEmployee < ActiveRecord::Migration[7.2]
  def change
    add_column :employees, :punching_absence, :boolean
  end
end
