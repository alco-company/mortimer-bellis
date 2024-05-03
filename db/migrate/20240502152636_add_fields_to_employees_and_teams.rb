class AddFieldsToEmployeesAndTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :teams, :payroll_team_ident, :string
    add_column :teams, :state, :string
    add_column :teams, :description, :text
    add_column :teams, :email, :string
    add_column :teams, :cell_phone, :string
    add_column :teams, :pbx_extension, :string
    add_column :teams, :contract_minutes, :integer
    add_column :teams, :contract_days_per_payroll, :integer
    add_column :teams, :contract_days_per_week, :integer
    add_column :teams, :hour_pay, :string
    add_column :teams, :ot1_add_hour_pay, :string
    add_column :teams, :ot2_add_hour_pay, :string
    add_column :teams, :hour_rate_cent, :integer, default: 0
    add_column :teams, :ot1_hour_add_cent, :integer, default: 0
    add_column :teams, :ot2_hour_add_cent, :integer, default: 0
    add_column :teams, :tmp_overtime_allowed, :datetime
    add_column :teams, :eu_state, :string
    add_column :teams, :blocked, :boolean
    add_column :teams, :allowed_ot_minutes, :integer
    add_column :employees, :allowed_ot_minutes, :integer
  end
end
