class User < ApplicationRecord
  include Localeable
  include Punchable
  include Settingable
  include Stateable
  include Taggable
  include Tenantable
  include TimeMaterialable
  include TimeZoned
  include Calendarable

  belongs_to :team

  has_many :background_jobs
  has_many :batches, dependent: :destroy
  has_many :filters, dependent: :destroy
  has_many :user_invitations, class_name: "User", as: :invited_by

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

  has_many :tasks, as: :tasked_for, dependent: :destroy

  enum :role, { user: 0, admin: 1, superadmin: 2 }
  has_one_attached :mugshot

  #
  # 6/10/2025 using it for unsubscribe links in emails!!!
  #
  has_secure_token :pos_token

  has_secure_password

  # OTP
  has_one_time_password
  attr_accessor :otp_code_token
  #

  has_secure_token :confirmation_token
  has_secure_token :invitation_token
  has_many :sessions, dependent: :destroy
  belongs_to :invited_by, polymorphic: true, optional: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # validates :password, presence: true
  validates :pincode,
    numericality: { only_integer: true, in: 1000..9999, unless: ->(u) { u.pincode.blank? } },
    uniqueness: { scope: :tenant_id, message: I18n.t("users.errors.messages.pincode_exist_for_tenant"), unless: ->(u) { u.pincode.blank? } }

  normalizes :email, with: ->(e) { e.strip.downcase }

  def signed_in?
    !current_sign_in_at.nil? && sessions.pluck(:updated_at).max > 8.hours.ago
  end

  def confirm!
    update!(confirmed_at: Time.current, confirmation_token: nil)
  end

  def confirmed?
    confirmed_at.present?
  end

  def send_confirmation_instructions
    regenerate_confirmation_token
    UserMailer.confirmation_instructions(self).deliver_later
  end

  def qr_code
    require "rqrcode"
    totp = ROTP::TOTP.new(otp_secret_key, issuer: "Mortimer")
    qrcode = RQRCode::QRCode.new(totp.provisioning_uri(email))
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 3,
      standalone: true,
      use_path: true
    )
  end

  def qr_code_as_text
    otp_secret_key.scan(/.{1,4}/).join(" ").upcase
  end

  attr_accessor :invitees, :invitation_message


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
  scope :by_team_users, ->(team) { where(id: team.users.pluck(:id)) if team.present? }

  def remove(step = nil)
    if tenant.users.count == 1 || step == "delete_account"
      TenantRegistrationService.call(tenant, {}, destroy: true)
    else
      begin
        UserMailer.with(user: self).user_farewell.deliver_later
      rescue => e
        UserMailer.error_report(e.to_s, "User#remove - failed for #{self&.email}").deliver_later
      end
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

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      # "email",
      # "encrypted_password",
      "reset_password_token",
      # "reset_password_sent_at",
      # "remember_created_at",
      # "sign_in_count",
      # "current_sign_in_at",
      # "last_sign_in_at",
      # "current_sign_in_ip",
      # "last_sign_in_ip",
      "confirmation_token",
      # "confirmed_at",
      # "confirmation_sent_at",
      # "role",
      # "locale",
      # "time_zone",
      # "created_at",
      # "updated_at",
      "invitation_token",
      # "invitation_created_at",
      # "invitation_sent_at",
      # "invitation_accepted_at",
      # "invitation_limit",
      "invited_by_type",
      "invited_by_id",
      # "invitations_count",
      # "name",
      # "global_queries",
      # "locked_at",
      # "failed_attempts",
      "unlock_token",
      # "team_id",
      # "state",
      # "eu_state",
      # "color",
      # "pincode",
      "pos_token",
      # "job_title",
      # "hired_at",
      # "birthday",
      # "last_punched_at",
      # "cell_phone",
      # "blocked_from_punching",
      # "consumed_timestep",
      # "otp_required_for_login",
      "otp_secret"
      # "otp_enabled",
      # "otp_enabled_at"
    ]
    f = f - [
      "reset_password_sent_at",
      "remember_created_at",
      "current_sign_in_at",
      "last_sign_in_at",
      "confirmed_at",
      "confirmation_sent_at",
      "created_at",
      "updated_at",
      "invitation_token",
      "invitation_created_at",
      "invitation_sent_at",
      "invitation_accepted_at",
      "hired_at",
      "last_punched_at",
      "otp_enabled_at",
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def notify(action: nil, title: nil, msg: nil, rcp: nil, priority: 0)
    recipient = rcp.blank? ? self : (rcp.is_a?(User) ? rcp : User.find(rcp))

    case action
    when :punch_reminder
      UserNotifier.with(record: self, current_user: Current.user, title: title, message: msg, delegator: self.name).deliver_later(recipient)
    when :destroy_all
      title ||= I18n.t("notifiers.no_title")
      msg ||=   I18n.t("notifiers.no_msg")
      UserNotifier.with(record: self, current_user: Current.user, title: title, message: msg, delegator: self.name).deliver_later(recipient)
    else
      UserNotifier.with(record: self, current_user: Current.user, title: title, message: msg, delegator: self.name).deliver_later(recipient)
    end
  rescue => e
    UserMailer.error_report(e.to_s, "User#notify - failed for #{self&.id}").deliver_later
  end

  def notified?(action)
    notifications.where(action: action).any?
  end

  def initials
    name.split(" ").map { |n| n[0] }.join.upcase
  end

  def self.form(resource:, editable: true, registration: false, **options)
    form_class = registration ? Users::Registrations::Form : Users::Form
    default_options = if registration
      {
        enctype: "multipart/form-data",
        class: "group mort-form",
        method: :put,
        data: { form_target: "form", profile_target: "buttonForm", controller: "profile password-strength" }
      }
    else
      { enctype: "multipart/form-data" }
    end
    LazyFormComponent.new(
      form_class: form_class,
      resource: resource,
      editable: editable,
      fields: options.delete(:fields) || [],
      **default_options.merge(options)
    )
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
    return true unless record.persisted?
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
