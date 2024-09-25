class User < ApplicationRecord
  include Localeable
  include Punchable
  include Stateable

  belongs_to :tenant
  belongs_to :team

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :confirmable, :trackable, :timeoutable, :lockable

  has_many :user_invitations, class_name: "User", as: :invited_by

  has_many :notifications, as: :recipient, class_name: "Noticed::Notification"

  enum :role, { user: 0, admin: 1, superadmin: 2 }
  has_one_attached :mugshot

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

  scope :by_email, ->(email) { where("email LIKE ?", "%#{email}%") if email.present? }
  scope :by_role, ->(role) { where(role: role) if role.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  # used by eg delete
  def name
    "#{email}"
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

  def self.form(resource, editable = true)
    Users::Form.new resource, editable: editable, enctype: "multipart/form-data"
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

  def in?
    true
  end
end
