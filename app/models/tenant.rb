class Tenant < ApplicationRecord
  #
  # add time zone support - if eg there is no user assigned when
  # some process executes
  #
  include TimeZoned
  include Localeable
  include Colorable
  include Calendarable
  include Setable
  include Serviceable

  has_many :background_jobs, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :filters, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :punch_cards, dependent: :destroy
  has_many :punch_clocks, dependent: :destroy
  has_many :punches, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :users, dependent: :destroy

  has_one_attached :logo
  has_secure_token :access_token

  scope :by_tenant, ->() { Current.user.global_queries? ? all : where(id: Current.tenant.id) }

  scope :by_name, ->(name) { where("name LIKE ? or email LIKE ?", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  validates :name, presence: true, uniqueness: { message: I18n.t("tenants.errors.messages.name_exist") }
  validates :email, presence: true

  def has_this_access_token(token)
    access_token == token
  end


  def all_calendars
    calendars
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Tenants::Form.new resource, editable: editable, enctype: "multipart/form-data"
  end

  def working_hours_this_week
    punch_cards.this_week.sum(:work_minutes) / 60
  end

  def extra_working_hours_this_week
    (punch_cards.this_week.sum(:ot1_minutes) + punch_cards.this_week.sum(:ot2_minutes)) / 60
  end

  def sick_absence_this_week
    punches.sick_absence.this_week.count
  end
end
