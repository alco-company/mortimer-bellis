class Location < ApplicationRecord
  LOCATION_COLORS = %w[red blue green yellow purple orange pink brown gray].collect { |color| { value: I18n.t("locations.colors.#{color}"), id: "border-#{color}-700" } }.freeze
  # LOCATION_COLORS = "red blue green yellow purple orange pink brown black"

  include Accountable
  has_many :punch_clocks, dependent: :destroy

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_location_color, ->(location_color) { where("location_color LIKE ?", "%#{location_color}%") if location_color.present? }

  validates :name, presence: true, uniqueness: { scope: :account_id, message: I18n.t("locations.errors.messages.name_exist") }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_account()
      .by_name(flt["name"])
      .by_location_color(flt["location_color"])
  rescue
    filter.destroy if filter
    all
  end

  def self.colors key = nil
    return LOCATION_COLORS if key.nil?
    LOCATION_COLORS.filter { |k| k[:id] == key }[0][:value]
  rescue
    key
  end

  def self.form(resource, editable = true)
    Locations::Form.new resource, editable: editable
  end
end
