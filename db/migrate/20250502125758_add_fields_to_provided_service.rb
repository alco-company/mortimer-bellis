class AddFieldsToProvidedService < ActiveRecord::Migration[8.1]
  def change
    add_column :provided_services, :last_sync_at, :datetime
    add_column :provided_services, :last_sync_status, :text
  end
end
