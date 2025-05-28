class ChangeReferenceToUserInTags < ActiveRecord::Migration[8.1]
  def change
    rename_column :tags, :created_by_id, :user_id
    rename_column :taggings, :tagger_id, :user_id
  end
end
