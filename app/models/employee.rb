class Employee < ApplicationRecord
  include Accountable
  include TimeZoned
  include Punchable
  include Localeable
  include Stateable
  include EUCompliance

  belongs_to :team
  has_many :punch_cards, dependent: :destroy
  has_many :punches, dependent: :destroy

  has_secure_token :access_token
  has_one_attached :mugshot do |attachable|
    attachable.variant :thumb, resize: "40x40"
    attachable.variant :small, resize: "100x100"
  end

  scope :by_name, ->(name) { where("name LIKE ? or pincode LIKE ? or payroll_employee_ident LIKE ? or job_title LIKE ? or cell_phone LIKE ? or email LIKE ?", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_team, ->(team) { joins(:team).where("teams.name LIKE ?", "%#{team}%") if team.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }
  scope :by_pincode, ->(pincode) { where("pincode LIKE ?", "%#{pincode}%").order(pincode: :asc) if pincode.present? }
  scope :punching_absence, -> { where(punching_absence: true) }
  scope :order_by_number, ->(field) { order("length(#{field}) DESC, #{field} DESC") }

  validates :name, presence: true, uniqueness: { scope: [ :account_id, :team_id ], message: I18n.t("employees.errors.messages.name_exist_for_team") }
  validates :pincode, presence: true, uniqueness: { scope: :account_id, message: I18n.t("employees.errors.messages.pincode_exist_for_account") }
  validates :payroll_employee_ident, presence: true, uniqueness: { scope: :account_id, message: I18n.t("employees.errors.messages.payroll_employee_ident_exist_for_account") }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_account()
      .by_name(flt["name"])
      .by_team(flt["team"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  def self.ordered(resources, field, direction = :desc)
    resources.joins(:team).order(field => direction)
  end

  def self.form(resource, editable = true)
    Employees::Form.new resource, editable: editable, enctype: "multipart/form-data"
  end

  def self.signup(resource, url, editable = true)
    Employees::Signup.new resource, action: url, editable: editable, enctype: "multipart/form-data"
  end

  #
  # extend this method on the model to define the field formats
  # its a callback from the superform when rendering the form
  # (in non-editable mode, the form will render the field value using this method)
  # see app/views/forms/application_form.rb#row
  #
  def field_formats(key)
    case key
    when :punching_absence;           :boolean
    else; super(key)
    end
  end

  def self.next_pincode(pin = "")
    pins = Employee.by_account.order_by_number("pincode").pluck(:pincode)
    pin = "1000" if pin.blank?
    return pin if pins.empty?
    pin = pins.first.to_i + 1 if pin.to_i < pins.first.to_i
    return pin unless (pins.include? pin) || (pin.to_i < 1000)
    while (pins.include? pin) || (pin.to_i < 1000)
      pin = pin.to_i + 1
    end
    pin.to_s
  end

  def self.next_payroll_employee_ident(pin)
    pins = Employee.by_account.order_by_number("payroll_employee_ident").pluck(:payroll_employee_ident)
    pin = "1" if pin.blank?
    return pin if pins.empty?
    pin = pins.first.to_i + 1 if pin.to_i < pins.first.to_i
    return pin unless pins.include? pin
    while pins.include? pin
      pin = pin.to_i + 1
    end
    pin.to_s
  end

  def get_team_color
    team.team_color.blank? ? "border-white" : team.team_color
  rescue
    "border-white"
  end
end
