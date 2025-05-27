class CreateEditorDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :editor_documents do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
