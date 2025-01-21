class Call < ApplicationRecord
  include Tenantable

  scope :by_fulltext, ->(query) { where("direction LIKE :query OR phone LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_direction, ->(direction) { where("direction LIKE ?", "%#{direction}%") if direction.present? }
  scope :by_phone, ->(phone) { where("phone LIKE ?", "%#{phone}%") if phone.present? }

  # validates :name, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("invoices.errors.messages.name_exist") }

  def self.set_order(resources, field = :created_at, direction = :desc)
    resources.ordered(field, direction)
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_direction(flt["direction"])
      .by_phone(flt["phone"])
  rescue
    filter.destroy if filter
    all
  end

  def name
    phone
  end
  # def self.form(resource:, editable: true)
  #   Invoices::Form.new resource: resource, editable: editable
  # end
end
