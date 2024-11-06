class RemoveForeignKeysInProduction < ActiveRecord::Migration[8.0]
  def change
    if Rails.env.production?
      remove_foreign_key "punch_cards", "employees"
      remove_foreign_key "punches", "employees"
    end
  end
end
