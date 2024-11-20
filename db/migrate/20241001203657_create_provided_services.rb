class CreateProvidedServices < ActiveRecord::Migration[8.0]
  def change
    create_table :provided_services do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :authorized_by, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.string :service
      t.text :params

      t.timestamps
    end
  end
end
