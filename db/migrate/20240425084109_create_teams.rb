class CreateTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :teams do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name
      t.string :team_color
      t.string :locale
      t.string :time_zone

      t.timestamps
    end
    add_foreign_key "teams", "accounts", on_delete: :cascade
  end
end
