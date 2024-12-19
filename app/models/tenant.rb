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
  has_many :calls, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :filters, dependent: :destroy
  has_many :invoice, dependent: :destroy
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

  #
  # make it possible to handle model deletion differently from model to model
  # eg TenantRegistrationService.call(tenant, destroy: true)
  def remove
    TenantRegistrationService.call(self, destroy: true)
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
    Task.where(tenant_id: 1).first_tasks.each do |first_task|
      unless tasks.first_tasks.map(&:priority).include?(first_task.priority)
        first_task.tenant = self
        first_task.tasked_for = users.first
        Task.create(first_task.attributes)
      end
    end

    # validate that all tasks are done
    tasks.first_tasks.uncompleted.each do |task|
      task.update completed_at: Time.current if eval(task.validation)
    end
  end

  # these are the "first" tasks that users should complete
  # soon after registration
  # they are not mandatory and only the first two is for the admin user only
  # the rest are for all users
  # the priority is negative so they are always on top of the list
  # and not included generally in any user's task list
  # and the negative value is a kind of unique ID across locales
  def possible_tasks
    {
      colleagues: {
        title: I18n.t("tasks.first_tasks.colleagues.title"),
        link: "/users/invitation/new",
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
        link: "/users/edit",
        priority: -4
      },
      notifications: {
        title: I18n.t("tasks.first_tasks.notifications.title"),
        link: "/users/edit",
        priority: -5
      }
    }
  end
end
