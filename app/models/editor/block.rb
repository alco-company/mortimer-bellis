class Editor::Block < ApplicationRecord
  self.table_name = "editor_blocks"
  belongs_to :document, class_name: "Editor::Document"
  belongs_to :parent, class_name: "Editor::Block", optional: true
  has_many :children, class_name: "Editor::Block", foreign_key: "parent_id", dependent: :destroy

  # acts_as_list scope: [ :document_id, :parent_id ]
  positioned on: [ :parent, :document ]

  # STI support (optional)
  self.inheritance_column = :_type_disabled

  store :data, accessors: [ :text, :src, :alt ]
  # `type` might be "paragraph", "heading", "image", etc.
  def data_parsed
    case data
    when ActiveSupport::HashWithIndifferentAccess
      data.to_h
    when Hash
      data
    when String
      begin
        JSON.parse(data) # .gsub("=>", ":").gsub(/:(\w+)/, '"\1"').gsub("nil", "null"))
      rescue JSON::ParserError
        {}
      end
    else
      {}
    end
  end
end
