class Editor::Block < ApplicationRecord
  self.table_name = "editor_blocks"
  # STI support (optional)
  self.inheritance_column = nil

  # NOTE: BackupTenantJob and RestoreTenantJob tests do not currently verify
  # self-referential parent/child relationships for this model. The parent_id
  # foreign key remapping should work but is untested.

  belongs_to :document, class_name: "Editor::Document", foreign_key: "document_id"
  belongs_to :parent, class_name: "Editor::Block", optional: true
  has_many :children, class_name: "Editor::Block", foreign_key: "parent_id", dependent: :destroy

  # mortimer_scoped - override on tables with other tenant scoping association
  scope :mortimer_scoped, ->(ids) { unscoped.where(document_id: ids) }

  def self.scoped_for_tenant(id = 1)
    ids = Editor::Document.where(tenant_id: id).pluck(:id)
    mortimer_scoped(ids)
  end

  # acts_as_list scope: [ :document_id, :parent_id ]
  #  positioned on: [ :parent, :document ]


  # store :data, accessors: [ :text, :src, :alt ]
  # # `type` might be "paragraph", "heading", "image", etc.
  # def data_parsed
  #   case data
  #   when ActiveSupport::HashWithIndifferentAccess
  #     data.to_h
  #   when Hash
  #     data
  #   when String
  #     begin
  #       JSON.parse(data) # .gsub("=>", ":").gsub(/:(\w+)/, '"\1"').gsub("nil", "null"))
  #     rescue JSON::ParserError
  #       {}
  #     end
  #   else
  #     {}
  #   end
  # end
end
