class RenameAccountToTenant < ActiveRecord::Migration[8.0]
  def change
    rename_table :accounts,         :tenants
    rename_column :tenants,         :account_color,   :color
    rename_column :events,          :event_color,     :color
    rename_column :locations,       :location_color,  :color
    rename_column :teams,           :team_color,      :color
    rename_column :background_jobs, :account_id,      :tenant_id
    rename_column :calendars,       :account_id,      :tenant_id
    rename_column :dashboards,      :account_id,      :tenant_id
    rename_column :events,          :account_id,      :tenant_id
    rename_column :filters,         :account_id,      :tenant_id
    rename_column :locations,       :account_id,      :tenant_id
    rename_column :punch_cards,     :account_id,      :tenant_id
    rename_column :punch_clocks,    :account_id,      :tenant_id
    rename_column :punches,         :account_id,      :tenant_id
    rename_column :settings,        :account_id,      :tenant_id
    rename_column :teams,           :account_id,      :tenant_id
    rename_column :users,           :account_id,      :tenant_id
  end
end
