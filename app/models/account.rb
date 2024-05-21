class Account < ApplicationRecord
  #
  # add time zone support - if eg there is no user assigned when
  # some process executes
  #
  include TimeZoned

  has_many :background_jobs, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :filters, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :punch_cards, dependent: :destroy
  has_many :punch_clocks, dependent: :destroy
  has_many :punches, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :users, dependent: :destroy

  has_one_attached :logo

  scope :by_account, ->() { Current.user.global_queries? ? all : where(id: Current.account.id) }

  scope :by_name, ->(name) { where("name LIKE ? or email LIKE ?", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  validates :name, presence: true, uniqueness: { message: I18n.t("accounts.errors.messages.name_exist") }
  validates :email, presence: true

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_account()
      .by_name(flt["name"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Accounts::Form.new resource, editable: editable, enctype: "multipart/form-data"
  end
end
