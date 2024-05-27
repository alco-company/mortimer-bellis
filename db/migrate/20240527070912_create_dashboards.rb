class CreateDashboards < ActiveRecord::Migration[7.2]
  def change
    create_table :dashboards do |t|
      t.references :account, null: false, foreign_key: true
      t.string :feed
      t.text :last_feed
      t.datetime :last_feed_at

      t.timestamps
    end
  end
end
