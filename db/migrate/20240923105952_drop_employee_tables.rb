class DropEmployeeTables < ActiveRecord::Migration[8.0]
  def up
    add_reference :users, :team, null: false, foreign_key: true, default: 1
    add_column :users, :state, :integer, default: 0
    add_column :users, :eu_state, :integer, default: 0
    add_column :users, :color, :string
    add_column :users, :pincode, :string
    add_column :users, :pos_token, :string
    add_column :users, :job_title, :string
    add_column :users, :hired_at, :datetime
    add_column :users, :birthday, :datetime
    add_column :users, :last_punched_at, :datetime
    add_column :users, :cell_phone, :string
    add_column :users, :blocked_from_punching, :boolean, default: false


    add_foreign_key "users", "teams", on_delete: :cascade
    add_foreign_key "users", "tenants", on_delete: :cascade
    remove_foreign_key "punch_cards", "employees"
    remove_foreign_key "punch_cards", "employees", on_delete: :cascade
    remove_foreign_key "punches", "employees"
    remove_foreign_key "punches", "employees", on_delete: :cascade

    rename_column :punch_cards, :employee_id, :user_id
    remove_index :punch_cards, :employee_id if index_exists? :punch_cards, :employee_id
    add_index :punch_cards, :user_id unless index_exists? :punch_cards, :user_id
    rename_column :punches, :employee_id, :user_id
    remove_index :punches, :employee_id if index_exists? :punches, :employee_id
    add_index :punches, :user_id unless index_exists? :punches, :user_id

    drop_table :employees if table_exists? :employees
    drop_table :employee_invitations if table_exists? :employee_invitations
  end
  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
