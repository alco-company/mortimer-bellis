class Tag < ApplicationRecord
  include Tenantable
  include Settingable
  has_many :taggings, dependent: :destroy
  has_many :taggables, through: :taggings
  belongs_to :created_by, class_name: "User", foreign_key: "user_id"
  validates :name, presence: true
  # validates :name, uniqueness: { scope: :tenant_id, message: I18n.t("tags.errors.messages.name_exist") }

  scope :by_fulltext, ->(query) { where("name LIKE :query OR category LIKE :query OR context LIKE :query ", query: "%#{query}%") if query.present? }
  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }

  validates :name, presence: true, uniqueness: { scope: :tenant_id, message: "already exists for this tenant" }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
  rescue
    filter.destroy if filter
    all
  end

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "category",
      "context",
      "user_id"
    ]
    f = f - [
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def self.associations
    [ [], [ Tagging ] ]
  end

  def self.form(resource:, editable: true)
    Tags::Form.new resource: resource, editable: editable # , fields: [ :title, :link, :description ]
  end
end
