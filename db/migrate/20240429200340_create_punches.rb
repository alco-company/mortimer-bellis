class CreatePunches < ActiveRecord::Migration[7.2]
  def change
    create_table :punches do |t|
      t.references :account, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.bigint :punch_clock_id
      t.datetime :punched_at
      t.string :state
      t.string :remote_ip

      t.timestamps
    end

    add_foreign_key "punches", "accounts", on_delete: :cascade
    add_foreign_key "punches", "employees", on_delete: :cascade
  end
end
