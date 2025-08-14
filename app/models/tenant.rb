class Tenant < ApplicationRecord
  LICENSE_TYPES = { trial: 0, free: 1, ambassador: 2, essential: 3, pro: 4 }
  #
  # add time zone support - if eg there is no user assigned when
  # some process executes
  #
  include TimeZoned
  include Localeable
  include Colorable
  include Calendarable
  include Setable # we need the tenant_id - not the polymorphic setable!
  include Serviceable

  has_many :background_jobs, dependent: :destroy
  has_many :batches, dependent: :destroy
  has_many :calls, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :filters, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :punch_cards, dependent: :destroy
  has_many :punch_clocks, dependent: :destroy
  has_many :punches, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :time_materials, dependent: :destroy
  has_many :users, dependent: :destroy

  has_one_attached :logo
  has_secure_token :access_token

  scope :by_tenant, ->() { Current.user.global_queries? ? all : where(id: Current.tenant.id) }

  scope :by_fulltext, ->(query) { where("name LIKE :query or email LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_name, ->(name) { where("name LIKE ? or email LIKE ?", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  validates :name, presence: true, uniqueness: { message: I18n.t("tenants.errors.messages.name_exist") }
  validates :email, presence: true

  enum :license, LICENSE_TYPES, default: :trial, scope: true

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

  def self.filterable_fields(model = self)
    f = column_names - [
      "id"
      # "name",
      # "email",
      # "pp_identification",
      # "locale",
      # "time_zone",
      # "created_at",
      # "updated_at",
      # "send_state_rrule",
      # "send_eu_state_rrule",
      # "color",
      # "tax_number",
      # "country",
      # "access_token"
    ]
    f = f - [
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  #
  # make it possible to handle model deletion differently from model to model
  # eg TenantRegistrationService.call(tenant, destroy: true)
  def remove(step = nil)
    TenantRegistrationService.call(self, {}, destroy: true)
  end

  def has_this_access_token(token)
    access_token == token
  end


  def all_calendars
    calendars
  end

  def self.form(resource:, editable: true)
    Tenants::Form.new resource: resource, editable: editable, enctype: "multipart/form-data"
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

  def check_tasks
    # tasks that should be done by the tenant
    fts = FirstTaskService.new(self, Current.user)
    fts.check
    fts.validate
  end

  # these are the "first" tasks that users should complete
  # soon after registration
  # they are not mandatory
  # and only the first 99 is for the admin user only
  # the rest are for all users
  # the priority is negative so they are always on top of the list
  # and not included generally in any user's task list
  # and the negative value is a kind of unique ID across locales
  def possible_tasks
    {
      colleagues: {
        title: I18n.t("tasks.first_tasks.colleagues.title"),
        link: "/users/invitations/new",
        priority: -1
      },
      dinero: {
        title: I18n.t("tasks.first_tasks.dinero.title"),
        link: "/provided_services/new?service=dinero",
        priority: -2
      },
      multi_factor: {
        title: I18n.t("tasks.first_tasks.multi_factor.title"),
        link: "dashboard_task_enable_2fa",
        priority: -3
      },
      profile: {
        title: I18n.t("tasks.first_tasks.profile.title"),
        link: "/users/registrations/edit",
        priority: -4
      },
      notifications: {
        title: I18n.t("tasks.first_tasks.notifications.title"),
        link: "/users/registrations/edit",
        priority: -5
      }
    }
  end

  def license_expires_shortly?
    license_expires_at.present? && license_expires_at < 1.week.from_now
  end
  # Returns true if the tenant's license rank is >= required level.
  def license_at_least?(required = :trial)
    if required.is_a?(Array)
      return required.all? { |r| license_at_least?(r) }
    end
    LICENSE_TYPES[license.to_sym] >= LICENSE_TYPES[required.to_sym]
  rescue
    true
  end

  # Valid if current license meets required level; trial also checks expiry.
  def license_valid?(required_license = :trial)
    # Maintain your trial auto-upgrade logic
    if license_expires_at.nil?
      update(license: :trial, license_expires_at: 4.week.from_now)
      UserMailer.info_report("license expiration not found", "tenants/#{id} #{name}'s license has been set to Trial with a 4 week grace period!").deliver_later
    end
    if license == "trial" && license_expires_at.present? && license_expires_at < Time.current
      update(license: :free, license_expires_at: 10.years.from_now)
      UserMailer.info_report("Trial license expired", "tenants/#{id} #{name}'s trial license has expired and was downgraded to a free license.").deliver_later
    end

    return false unless license_at_least?(required_license)

    # Only trial depends on expiry; paid tiers are always valid here
    return true unless license == "trial"
    license_expires_at.nil? || (license_expires_at.present? && license_expires_at.future?)
  end

  def license_expired?
    !license_valid?
  end

  def licenses(lic = nil)
    if lic.present?
      self.license=lic.to_i
      return self.license
    end
    {
      trial: I18n.t("tenants.licenses.trial"),
      free: I18n.t("tenants.licenses.free"),
      ambassador: I18n.t("tenants.licenses.ambassador"),
      essential: I18n.t("tenants.licenses.essential"),
      pro: I18n.t("tenants.licenses.pro")
    }
  end
end
