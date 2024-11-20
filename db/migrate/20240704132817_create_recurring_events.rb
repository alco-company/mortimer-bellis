class CreateRecurringEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :recurring_events do |t|
      t.text :recurrence

      t.timestamps
    end
  end
end
