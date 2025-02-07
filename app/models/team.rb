class Team < ApplicationRecord
  include Tenantable
  include Colorable
  include Localeable
  include Stateable
  include Calendarable
  include TimeZoned

  has_many :users
  has_many :punch_cards, through: :users
  # has_and_belongs_to_many :users

  scope :by_fulltext, ->(query) { where("name LIKE :query OR color LIKE :query OR locale LIKE :query OR time_zone LIKE :query", query: "%#{query}%") if query.present? }
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

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      # "name",
      # "color",
      # "locale",
      # "time_zone",
      # "payroll_team_ident",
      # "state",
      # "description",
      # "email",
      # "cell_phone",
      # "pbx_extension",
      # "contract_minutes",
      # "contract_days_per_payroll",
      # "contract_days_per_week",
      # "hour_pay",
      # "ot1_add_hour_pay",
      # "ot2_add_hour_pay",
      "hour_rate_cent",
      "ot1_hour_add_cent",
      "ot2_hour_add_cent"
      # "eu_state",
      # "blocked",
      # "allowed_ot_minutes",
      # "country",
      # "created_at",
      # "updated_at",
      # "punches_settled_at",
      # "tmp_overtime_allowed"
    ]
    f = f - [
      "created_at",
      "updated_at",
      "punches_settled_at",
      "tmp_overtime_allowed"
    ] if model == self
    f
  end

  def self.associations
    [ [], [ PunchCard ] ]
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
