class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :account, null: false, foreign_key: true
      t.references :calendar, null: false, foreign_key: true
      t.string :name
      t.date :from_date
      t.datetime :from_time
      t.date :to_date
      t.datetime :to_time
      t.integer :duration
      t.boolean :auto_punch
      t.boolean :all_day
      t.text :comment

      t.timestamps
    end
  end
end
