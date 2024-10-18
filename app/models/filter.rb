class Filter < ApplicationRecord
  include Tenantable

  scope :by_view, ->(view) { where("view LIKE ?", "%#{view}%") if view.present? }

  def self.filtered(filter)
    flt = filter.filter

    all
      # .by_tenant()
      .by_view(flt["view"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource:, editable: true)
    Filters::Form.new resource
  end
end
