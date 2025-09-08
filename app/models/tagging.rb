class Tagging < ApplicationRecord
  belongs_to :taggable, polymorphic: true
  belongs_to :tag
  belongs_to :tagger, class_name: "User", foreign_key: "user_id"

  # mortimer_scoped - override on tables with other tenant scoping association
  scope :mortimer_scoped, ->(ids) { unscoped.where(tag_id: ids) } # effectively returns no records

  def self.scoped_for_tenant(id = 1)
    ids = Tag.where(tenant_id: id).pluck(:id)
    mortimer_scoped(ids)
  end
end
