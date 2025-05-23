class Editor::Block < ApplicationRecord
  belongs_to :document, class_name: "Editor::Document"
  belongs_to :parent, class_name: "Editor::Block", optional: true
  has_many :children, class_name: "Editor::Block", foreign_key: "parent_id", dependent: :destroy

  acts_as_list scope: [ :document_id, :parent_id ]

  # STI support (optional)
  self.inheritance_column = :_type_disabled

  # `type` might be "paragraph", "heading", "image", etc.
end
