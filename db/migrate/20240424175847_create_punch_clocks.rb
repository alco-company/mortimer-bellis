class CreatePunchClocks < ActiveRecord::Migration[7.2]
  def change
    create_table :punch_clocks do |t|
      t.references :account, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.string :name
      t.string :ip_addr
      t.datetime :last_punched_at
      t.string :access_token
      t.string :locale
      t.string :time_zone

      t.timestamps
    end
  end
end
