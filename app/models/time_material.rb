class TimeMaterial < ApplicationRecord
  include Tenantable
  include TimeMaterialStateable

  belongs_to :customer, optional: true
  belongs_to :project, optional: true
  belongs_to :product, optional: true

  scope :by_about, ->(about) { where("about LIKE ?", "%#{about}%") if about.present? }

  validates :about, presence: true

  def list_item(links: [], context:)
    TimeMaterialDetailItem.new(item: self, links: links, id: context.dom_id(self))
  end

  def name
    about[..50]
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

  def self.form(resource, editable = true)
    Locations::Form.new resource, editable: editable
  end
end
