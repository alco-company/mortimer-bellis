class AddPunchCardRelationToPunch < ActiveRecord::Migration[7.2]
  def change
    add_column :punches, :punch_card_id, :integer, null: true
    add_foreign_key "punches", "punch_cards", on_delete: :cascade
  end
end
