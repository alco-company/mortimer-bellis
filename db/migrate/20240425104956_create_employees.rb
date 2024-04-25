class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.references :account, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :name
      t.string :pincode
      t.string :payroll_employee_ident
      t.string :access_token
      t.datetime :last_punched_at
      t.datetime :punches_settled_at
      t.string :state
      t.string :job_title
      t.datetime :birthday
      t.datetime :hired_at
      t.text :description
      t.string :email
      t.string :cell_phone
      t.string :pbx_extension
      t.integer :contract_minutes
      t.integer :contract_days_per_payroll
      t.integer :contract_days_per_week
      t.integer :flex_balance_minutes
      t.string :hour_pay
      t.string :ot1_add_hour_pay
      t.string :ot2_add_hour_pay
      t.integer :hour_rate_cent, default: 0
      t.integer :ot1_hour_add_cent, default: 0
      t.integer :ot2_hour_add_cent, default: 0
      t.datetime :tmp_overtime_allowed
      t.string :eu_state
      t.boolean :blocked
      t.string :locale
      t.string :time_zone

      t.timestamps
    end

    add_column :teams, :punches_settled_at, :datetime
    
    add_foreign_key "employees", "accounts", on_delete: :cascade
    add_foreign_key "employees", "teams", on_delete: :cascade

  end
end
