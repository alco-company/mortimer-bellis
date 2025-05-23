class CreateEditorBlocks < ActiveRecord::Migration[8.1]
  def change
    create_table :editor_blocks do |t|
      t.references :document, null: false, foreign_key: true
      t.integer :parent_id
      t.string :type
      t.text :data
      t.integer :position

      t.timestamps
    end
  end
end
