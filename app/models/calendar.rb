class Calendar < ApplicationRecord
  include Tenantable
  belongs_to :calendarable, polymorphic: true
  has_many :events, dependent: :destroy

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }


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
      "tenant_id"
      # t.string "name"
      # t.string "product_number"
      # t.decimal "quantity", precision: 9, scale: 3
      # t.string "unit"
      # t.integer "account_number"
      # t.decimal "base_amount_value", precision: 11, scale: 2
      # t.decimal "base_amount_value_incl_vat", precision: 11, scale: 2
      # t.decimal "total_amount", precision: 11, scale: 2
      # t.decimal "total_amount_incl_vat", precision: 11, scale: 2
      # t.string "external_reference"
    ]
    f = f - [
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def self.associations
    [ [], [] ]
  end

  def self.form(resource:, editable: true)
    Calendars::Form.new resource: resource, editable: editable
  end

  def time_zone
    calendarable.time_zone || Current.user.time_zone || Current.tenant.time_zone rescue nil
  end

  def punch_cards(rg)
    calendarable.punch_cards.where(work_date: rg)
  end
end
