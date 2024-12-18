class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :state
      t.integer :priority
      t.datetime :due_at
      t.integer :progress
      t.datetime :completed_at
      t.boolean :archived

      t.timestamps
    end
  end
end
