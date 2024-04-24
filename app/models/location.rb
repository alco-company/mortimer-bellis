class Location < ApplicationRecord
  include Accountable
  has_many :punch_clocks, dependent: :destroy

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_location_color, ->(location_color) { where("location_color LIKE ?", "%#{location_color}%") if location_color.present? }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_name(flt["name"])
      .by_location_color(flt["location_color"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Locations::Form.new resource, editable: editable
  end
end
