class TimeMaterial < ApplicationRecord
  include Tenantable

  scope :by_about, ->(about) { where("about LIKE ?", "%#{about}%") if about.present? }

  validates :about, presence: true

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_about(flt["about"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Locations::Form.new resource, editable: editable
  end
end
