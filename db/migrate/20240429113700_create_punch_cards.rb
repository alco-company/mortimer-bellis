class CreatePunchCards < ActiveRecord::Migration[7.2]
  def change
    create_table :punch_cards do |t|
      t.references :account, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.date :work_date
      t.integer :work_minutes
      t.integer :ot1_minutes
      t.integer :ot2_minutes
      t.integer :break_minutes
      t.datetime :punches_settled_at

      t.timestamps
    end

    add_foreign_key "punch_cards", "accounts", on_delete: :cascade
    add_foreign_key "punch_cards", "employees", on_delete: :cascade
  end
end
