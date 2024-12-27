class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :tasked_for, polymorphic: true
      t.string :title
      t.string :link
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
