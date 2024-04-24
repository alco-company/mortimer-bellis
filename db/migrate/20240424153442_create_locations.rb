class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name
      t.string :location_color

      t.timestamps
    end
  end
end
