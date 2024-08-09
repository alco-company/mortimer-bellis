class Event < ApplicationRecord
  include Accountable
  belongs_to :calendar

  has_many_attached :files
  has_one :event_metum, dependent: :destroy

  # accepts_nested_attributes_for :event_metum
  def event_metum_attributes=(attributes)
    event_metum = self.event_metum || build_event_metum
    event_metum.from_params params: attributes, tz: calendar.time_zone
    event_metum.save
  end

  def name
    super || I18n.t("events.default_name")
  end

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_account()
      .by_name(flt["name"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    Events::Form.new resource, editable: editable, enctype: "multipart/form-data"
  end
end
