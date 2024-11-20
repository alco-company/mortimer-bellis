class RemoveRecurringEvents < ActiveRecord::Migration[8.0]
  def up
    drop_table :recurring_events, if_exists: true
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
    puts "The RecurringEvent model is not used - see EventMeta"
  end
end
