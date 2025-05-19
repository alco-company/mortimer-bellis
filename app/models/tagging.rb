class Tagging < ApplicationRecord
  belongs_to :taggable, polymorphic: true
  belongs_to :tag
  belongs_to :tagger, class_name: "User", foreign_key: "user_id"
end
