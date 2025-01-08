class User < ApplicationRecord
  include Tenantable
  include Localeable
  include Punchable
  include Stateable
  include TimeZoned
  include Settingable

  belongs_to :team

  # Include default devise modules. Others available are:
  # :database_authenticatable, :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :two_factor_authenticatable, :two_factor_backupable, otp_secret_encryption_key: ENV["OTP_KEY"]
  devise :two_factor_authenticatable
  devise :omniauthable, omniauth_providers: %i[ entra_id ]
  devise :timeoutable, timeout_in: 7.days #  ((Time.now.end_of_week - 1.day) - Time.now).minutes
  devise :invitable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :lockable

  has_many :user_invitations, class_name: "User", as: :invited_by
  has_many :time_materials

  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :web_push_subscriptions, class_name: "Noticed::WebPush::Subscription", as: :user, dependent: :destroy
  has_many :provided_services, foreign_key: "authorized_by_id", inverse_of: :authorized_by

  has_many :access_grants,
           class_name: "Doorkeeper::AccessGrant",
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: "Doorkeeper::AccessToken",
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :tasks, as: :tasked_for

  enum :role, { user: 0, admin: 1, superadmin: 2 }
  has_one_attached :mugshot
  has_secure_token :pos_token

  scope :by_tenant, ->() {
    if Current.user.present?
       case Current.user.role
       when "superadmin"
         Current.user.global_queries? ? all : where(tenant: Current.tenant)
       when "admin"
         where(tenant: Current.tenant)
       when "user"
         where(tenant: Current.tenant, id: Current.user.id)
       end
    else
      all
    end
  }

  scope :by_fulltext, ->(query) { where("email LIKE :query or role LIKE :query or locale  LIKE :query or time_zone LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_email, ->(email) { where("email LIKE ?", "%#{email}%") if email.present? }
  scope :by_role, ->(role) { where(role: role) if role.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  validates :pincode,
    numericality: { only_integer: true, in: 1000..9999, unless: ->(u) { u.pincode.blank? } },
    uniqueness: { scope: :tenant_id, message: I18n.t("users.errors.messages.pincode_exist_for_tenant"), unless: ->(u) { u.pincode.blank? } }

  def remove(step = nil)
    if tenant.users.count == 1 || step == "delete_account"
      TenantRegistrationService.call(tenant, destroy: true)
    else
      UserMailer.with(user: self).user_farewell.deliver
      destroy!
    end
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_email(flt["email"])
      .by_role(flt["role"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  def notify(action: nil, title: nil, msg: nil, rcp: nil, priority: 0)
    recipient = rcp.blank? ? self : (rcp.is_a?(User) ? rcp : User.find(rcp))

    case action
    when :punch_reminder
      UserNotifier.with(record: self, current_user: Current.user, title: title, message: msg, delegator: self.name).deliver(recipient)
    when :destroy_all
      title ||= I18n.t("notifiers.no_title")
      msg ||=   I18n.t("notifiers.no_msg")
      UserNotifier.with(record: self, current_user: Current.user, title: title, message: msg, delegator: self.name).deliver(recipient)
    end
  end

  def initials
    name.split(" ").map { |n| n[0] }.join.upcase
  end

  def self.form(resource:, editable: true)
    Users::Form.new resource: resource, editable: editable, enctype: "multipart/form-data"
  end

  def add_role
    r = 0
    begin
      r = 2 if Tenant.unscoped.count == 1
      r = 1 if self.tenant.users.count == 1
    rescue
    end

    self.update(role: r)
  end

  #
  # basically superadmin can do anything
  # whereas admins can only do things within their tenant
  # and users can only do things within their tenant and for themselves
  # called from ressourceable.rb
  #
  def allowed_to?(action, record)
    case role
    when "superadmin"
      true
    else
      case record.class.to_s
      when "Tenant"; record == tenant
      when "User"; admin? ? record.tenant == tenant : record == self
      else
        record.respond_to?(:tenant) ? record.tenant == tenant :
        record.respond_to?(:user) ? record.user == self :
        record.respond_to?(:resource_owner_id) ? record.resource_owner_id == id : false
      end
    end
  end

  def get_team_color
    team.color.blank? ? "border-white" : team.color
  rescue
    "border-white"
  end

  # -----
  def minutes_today_up_to_now
    { work: 0, break: 0 }
  end

  def todays_punches
    []
  end

  def punches_settled_at
    Time.now
  end
end
