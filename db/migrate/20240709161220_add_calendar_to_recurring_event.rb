class AddCalendarToRecurringEvent < ActiveRecord::Migration[8.0]
  def change
    add_reference :recurring_events, :calendar, null: false, foreign_key: true
    RecurringEvent.delete_all
    add_foreign_key "recurring_events", "calendars", on_delete: :cascade
  end
end
