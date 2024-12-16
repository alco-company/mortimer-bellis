class CreateCalls < ActiveRecord::Migration[8.1]
  def change
    create_table :calls do |t|
      t.references :tenant, null: false, foreign_key: true
      t.integer :direction
      t.string :phone

      t.timestamps
    end
  end
end
