class Employee < ApplicationRecord
  include Accountable
  include TimeZoned

  belongs_to :team

  has_secure_token :access_token

  scope :by_name, ->(name) { where("name LIKE ? or pincode LIKE ? or employee_ident LIKE ? or job_title LIKE ? or cell_phone LIKE ? or email LIKE ?", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%") if name.present? }
  scope :by_team, ->(team) { where("team LIKE ?", "%#{team}%") if team.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }
  scope :by_pincode, ->(pincode) { where("pincode LIKE ?", "%#{pincode}%").order(pincode: :asc) if pincode.present? }

  validates :name, presence: true

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_name(flt["name"])
      .by_team(flt["team"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Employees::Form.new resource, editable: editable
  end

  def self.next_pincode(pin)
    pins = Employee.pluck(:pincode).compact.sort
    pin = "0001" if pin.blank?
    return pin if pins.empty?
    pin = pins.last.to_i + 1 if pin.to_i < pins.last.to_i
    return pin unless pins.include? pin
    while pins.include? pin
      pin = pin.to_i + 1
    end
    pin.to_s
  end
end
