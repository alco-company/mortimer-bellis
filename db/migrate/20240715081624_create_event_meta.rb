class CreateEventMeta < ActiveRecord::Migration[8.0]
  def change
    create_table :event_meta do |t|
      t.references :event, null: false, foreign_key: true
      t.string :days
      t.string :weeks
      t.string :weekdays
      t.string :months
      t.string :years
      t.text :rrule
      t.text :ice_cube
      t.text :ui_values

      t.timestamps
    end
  end
end
