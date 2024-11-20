class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :erp_guid
      t.string :name
      t.string :street
      t.string :zipcode
      t.string :city
      t.string :phone
      t.string :email
      t.string :vat_number
      t.string :ean_number

      t.timestamps
    end
  end
end
