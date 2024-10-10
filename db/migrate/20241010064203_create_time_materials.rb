class CreateTimeMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :time_materials do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :date
      t.string :time
      t.string :about
      t.string :customer
      t.string :customer_id
      t.string :project
      t.string :project_id
      t.string :product
      t.string :product_id
      t.string :quantity
      t.string :rate
      t.string :discount
      t.boolean :is_invoice
      t.boolean :is_free
      t.boolean :is_offer
      t.boolean :is_separate

      t.timestamps
    end
  end
end
