class Event < ApplicationRecord
  include Tenantable
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

  scope :by_fulltext, ->(query) { where("name LIKE :query OR description LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
  rescue
    filter.destroy if filter
    all
  end

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "calendar_id"
      # "name"
      # "from_date"
      # "from_time"
      # "to_date"
      # "to_time"
      # "duration"
      # "auto_punch"
      # "all_day"
      # "comment"
      # "created_at",
      # "updated_at",
      # "work_type"
      # "reason"
      # "break_minutes"
      # "breaks_included"
      # "color"
    ]
    f = f - [
      "from_date",
      "from_time",
      "to_date",
      "to_time",
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def self.form(resource:, editable: true)
    Events::Form.new resource: resource, editable: editable, enctype: "multipart/form-data"
  end

  # call event_metum.get_field(:field_name) to get the value of the field
  # return "" if no event_metum exist
  def get_field(field_name)
    return "" unless event_metum

    event_metum.get_field(field_name)
  end

  def occurs?(window, dt, tz)
    return false if !from_date.nil? && from_date.to_date > dt
    return false if !to_date.nil? && to_date.to_date < dt
    return true  if event_metum.nil?
    occurs_on?(dt, window, tz)
  end

  def occurs_on?(dt, window, tz)
    event_metum.occurs_on?(dt, window, tz)
  end
end
