class Filter < ApplicationRecord
  belongs_to :account

  scope :by_view, ->(view) { here("view LIKE ?", "%#{view}%") if view.present? }

  def self.filtered(filter)
    flt = JSON.parse filter.filter

    all
      .by_view(flt["view"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource)
    Filters::Form.new resource
  end
end
