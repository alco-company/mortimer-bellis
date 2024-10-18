class Team < ApplicationRecord
  include Tenantable
  include Colorable
  include Localeable
  include Stateable
  include Calendarable

  has_many :users, dependent: :destroy
  has_many :punch_cards, through: :users
  # has_and_belongs_to_many :users

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_team_color, ->(team_color) { where("color LIKE ?", "%#{team_color}%") if team_color.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  validates :name, presence: true, uniqueness: { scope: :tenant_id, message: "already exists for this tenant" }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
      .by_team_color(flt["team_color"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  def all_calendars
    tenant.calendars + calendars
  end

  def self.form(resource:, editable: true)
    Teams::Form.new resource: resource, editable: editable
  end

  def get_allowed_ot_minutes
    return 24*60 if allowed_ot_minutes.nil?
    return 24*60 if allowed_ot_minutes == 0
    return -1 if allowed_ot_minutes < 0
    allowed_ot_minutes
  end

  def days_per_payroll
    contract_days_per_payroll
  rescue
    0
  end
end
