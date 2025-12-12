class Location < ApplicationRecord
  include Tenantable
  include Settingable
  include Colorable

  has_many :punch_clocks, dependent: :destroy

  scope :by_fulltext, ->(query) { where("name LIKE :query or color LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_location_color, ->(location_color) { where("color LIKE ?", "%#{location_color}%") if location_color.present? }

  validates :name, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("locations.errors.messages.name_exist") }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
      .by_location_color(flt["location_color"])
  rescue
    filter.destroy if filter
    all
  end

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id"
      # "name"
      # "color"
      # "created_at", null: false
      # "updated_at", null: false
    ]
    f = f - [
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def self.associations
    [ [], [ PunchClock ] ]
  end

  def self.form(resource:, editable: true)
    Locations::Form.new resource: resource, editable: editable
  end
end
