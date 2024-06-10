class AddFkeyDashboards < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key "dashboards", "accounts", on_delete: :cascade
  end
end
