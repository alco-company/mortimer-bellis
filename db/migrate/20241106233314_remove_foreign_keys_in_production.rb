class RemoveForeignKeysInProduction < ActiveRecord::Migration[8.0]
  def up
    if Rails.env.production?
      create_table :employees do |t|
        t.string :body
      end
      remove_foreign_key "punch_cards", "employees"
      remove_foreign_key "punches", "employees"
      drop_table :employees if table_exists? :employees
    end
  end
end
