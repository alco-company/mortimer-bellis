class AddForeignKeyToFilters < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key "filters", "accounts", on_delete: :cascade
  end
end
