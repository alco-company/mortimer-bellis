class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.references :tenant, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :state
      t.decimal :budget, precision: 11, scale: 2
      t.boolean :is_billable
      t.boolean :is_separate_invoice
      t.decimal :hourly_rate, precision: 11, scale: 2
      t.integer :priority
      t.integer :estimated_minutes
      t.integer :actual_minutes

      t.timestamps
    end
  end
end
