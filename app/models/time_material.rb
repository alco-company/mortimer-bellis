class TimeMaterial < ApplicationRecord
  include Tenantable
  include TimeMaterialStateable

  belongs_to :customer, optional: true
  belongs_to :project, optional: true
  belongs_to :product, optional: true
  belongs_to :user

  scope :by_fulltext, ->(query) { includes([ :customer, :project, :product ]).references([ :customers, :projects, :products ]).where("customers.name LIKE :query OR projects.name like :query or products.name like :query or products.product_number like :query or about LIKE :query OR product_name LIKE :query OR comment LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_about, ->(about) { where("about LIKE ?", "%#{about}%") if about.present? }
  scope :by_exact_user, ->(user) { where("user_id= ?", "%#{user.id}%") if user.present? }

  # validates :about, presence: true

  validates :about, presence: true, if: [ Proc.new { |c| c.comment.blank? && c.product_name.blank? } ]

  def self.set_order(resources, field = :created_at, direction = :desc)
    resources.ordered(field, direction)
  end

  def list_item(links: [], context:)
    TimeMaterialDetailItem.new(item: self, links: links, id: context.dom_id(self))
  end

  def name
    about[..50]
    case false
    when product_name.blank?; product_name[..50]
    when about.blank?; about[..50]
    when comment.blank?; comment[..50]
    end
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_about(flt["about"])
  rescue
    filter.destroy if filter
    all
  end

  def has_mugshot?
    false
  end

  def self.form(resource:, editable: true)
    TimeMaterials::Form.new resource: resource, editable: editable
  end

  def units
    [
      [ "hours", I18n.t("time_material.units.hours") ],
      [ "parts", I18n.t("time_material.units.parts") ],
      [ "km", I18n.t("time_material.units.km") ],
      [ "day", I18n.t("time_material.units.day") ],
      [ "week", I18n.t("time_material.units.week") ],
      [ "month", I18n.t("time_material.units.month") ],
      [ "kilogram", I18n.t("time_material.units.kilogram") ],
      [ "cubicMetre", I18n.t("time_material.units.cubicMetre") ],
      [ "set", I18n.t("time_material.units.set") ],
      [ "litre", I18n.t("time_material.units.litre") ],
      [ "box", I18n.t("time_material.units.box") ],
      [ "case", I18n.t("time_material.units.case") ],
      [ "carton", I18n.t("time_material.units.carton") ],
      [ "metre", I18n.t("time_material.units.metre") ],
      [ "package", I18n.t("time_material.units.package") ],
      [ "shipment", I18n.t("time_material.units.shipment") ],
      [ "squareMetre", I18n.t("time_material.units.squareMetre") ],
      [ "session", I18n.t("time_material.units.session") ],
      [ "tonne", I18n.t("time_material.units.tonne") ]
    ]
  end
end
