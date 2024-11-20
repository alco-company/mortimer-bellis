class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :erp_guid
      t.string :name
      t.string :product_number
      t.decimal :quantity, precision: 9, scale: 3
      t.string :unit
      t.integer :account_number
      t.decimal :base_amount_value, precision: 11, scale: 2
      t.decimal :base_amount_value_incl_vat, precision: 11, scale: 2
      t.decimal :total_amount, precision: 11, scale: 2
      t.decimal :total_amount_incl_vat, precision: 11, scale: 2
      t.string :external_reference

      t.timestamps
    end
  end
end
