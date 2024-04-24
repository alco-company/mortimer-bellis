class Foreignkeys < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key "filters", "accounts"
    remove_foreign_key "locations", "accounts"
    remove_foreign_key "punch_clocks", "accounts"
    remove_foreign_key "punch_clocks", "locations"

    add_foreign_key "filters", "accounts"
    add_foreign_key "locations", "accounts", on_delete: :cascade
    add_foreign_key "punch_clocks", "accounts", on_delete: :cascade
    add_foreign_key "punch_clocks", "locations", on_delete: :cascade
  end
end
