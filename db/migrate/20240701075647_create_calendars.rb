class CreateCalendars < ActiveRecord::Migration[8.0]
  def change
    create_table :calendars do |t|
      t.references :account, null: false, foreign_key: true
      t.references :calendarable, polymorphic: true, null: false
      t.string :name

      t.timestamps
    end
  end
end
