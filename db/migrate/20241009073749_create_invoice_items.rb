class CreateInvoiceItems < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_items do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true
      t.integer :project_id
      t.references :product, null: false, foreign_key: true
      t.string :product_guid
      t.string :description
      t.text :comments
      t.decimal :quantity
      t.string :account_number
      t.string :unit
      t.decimal :discount
      t.string :line_type
      t.decimal :base_amount_value
      t.decimal :base_amount_value_incl_vat
      t.decimal :total_amount
      t.decimal :total_amount_incl_vat

      t.timestamps
    end
  end
end
