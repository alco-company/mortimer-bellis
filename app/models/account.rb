class Account < ApplicationRecord
  #
  # add time zone support - if eg there is no user assigned when
  # some process executes
  #
  include TimeZoned

  has_many :users, dependent: :destroy
  has_many :filters, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :punch_clocks, dependent: :destroy
  has_many :teams, dependent: :destroy


  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_locale, ->(locale) { where("locale LIKE ?", "%#{locale}%") if locale.present? }
  scope :by_time_zone, ->(time_zone) { where("time_zone LIKE ?", "%#{time_zone}%") if time_zone.present? }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_name(flt["name"])
      .by_locale(flt["locale"])
      .by_time_zone(flt["time_zone"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Accounts::Form.new resource, editable: editable
  end
end
