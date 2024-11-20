class CreateHolidays < ActiveRecord::Migration[8.0]
  def change
    create_table :holidays do |t|
      t.string :name
      t.string :countries
      t.date :from_date
      t.date :to_date
      t.integer :all_day

      t.timestamps
    end
  end
end
