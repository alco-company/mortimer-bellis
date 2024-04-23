class CreateFilters < ActiveRecord::Migration[7.2]
  def change
    create_table :filters do |t|
      t.references :account, null: false, foreign_key: true
      t.string :view
      t.json :filter

      t.timestamps
    end
  end
end
