class User < ApplicationRecord
  belongs_to :account

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :confirmable, :trackable, :timeoutable

  enum :role, { user: 0, admin: 1, superadmin: 2 }

  scope :by_account, ->() {
    if Current.user.present?
       case Current.user.role
       when "superadmin"
         Current.user.global_queries? ? all : where(account: Current.account)
       when "admin"
         where(account: Current.account)
       when "user"
         where(account: Current.account, id: Current.user.id)
       end
    else
      all
    end
  }

  scope :by_email, ->(email) { where("email LIKE ?", "%#{email}%") if email.present? }
  scope :by_role, ->(role) { where(role: role) if role.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_account()
      .by_email(flt["email"])
      .by_role(flt["role"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Users::Form.new resource, editable: editable
  end

  def add_role
    r = 1 if self.account.users.count == 1
    r = 2 if Account.unscoped.count == 1
    self.update(role: r || 0)
  end
end
