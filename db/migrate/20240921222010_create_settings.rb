class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      t.references :account, null: false, foreign_key: true
      t.references :setable, polymorphic: true, null: true
      t.string :key
      t.integer :priority
      t.string :format
      t.string :value

      t.timestamps
    end
  end
end
