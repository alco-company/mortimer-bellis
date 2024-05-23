class CreateBackgroundJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :background_jobs do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: true
      t.integer :state, default: 0
      t.string :job_klass
      t.text :params
      t.text :schedule
      t.datetime :next_run_at
      t.string :job_id

      t.timestamps
    end
    add_foreign_key "background_jobs", "accounts", on_delete: :cascade
  end
end
