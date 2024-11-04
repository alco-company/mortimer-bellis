class PunchClock < ApplicationRecord
  include Tenantable
  include Localeable
  belongs_to :location
  has_many :punches, dependent: :destroy

  has_secure_token :access_token

  scope :by_fulltext, ->(query) { where("name LIKE :query OR ip_addr LIKE :query OR locale LIKE :query OR time_zone LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_location, ->(location) { joins(:location).where("locations.name LIKE ?", "%#{location}%") if location.present? }
  scope :by_ip_addr, ->(ip_addr) { where("ip_addr LIKE ?", "%#{ip_addr}%") if ip_addr.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  validates :name, presence: true, uniqueness: { scope: :tenant_id, message: "already exists for this tenant" }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
      .by_location(flt["location"])
      .by_ip_addr(flt["ip_addr"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  # def self.ordered(resources, field, direction = :desc)
  #   resources.joins(:location).order(field => direction)
  # end

  def self.form(resource:, editable: true)
    PunchClocks::Form.new resource: resource, editable: editable
  end
end
