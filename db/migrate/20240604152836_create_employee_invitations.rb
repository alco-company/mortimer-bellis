class CreateEmployeeInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :employee_invitations do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :address
      t.string :access_token
      t.integer :state
      t.datetime :invited_at
      t.datetime :seen_at
      t.datetime :completed_at

      t.timestamps
    end
    add_foreign_key "employee_invitations", "accounts", on_delete: :cascade
    add_foreign_key "employee_invitations", "users", on_delete: :cascade
    add_foreign_key "employee_invitations", "teams", on_delete: :cascade
  end
end
