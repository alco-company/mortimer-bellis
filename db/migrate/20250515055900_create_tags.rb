class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.string :category
      t.string :context
      t.integer :count, default: 0

      t.timestamps
    end
    add_index :tags, [ :tenant_id, :context, :name ], unique: true
    add_index :tags, [ :tenant_id, :category, :name ], unique: true

    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false
      t.references :tagger, null: false, foreign_key: { to_table: :users }
      t.string :context

      t.datetime :created_at, null: false
    end
    add_index :taggings, [ :tag_id, :taggable_id, :taggable_type, :context ], unique: true
  end
end
