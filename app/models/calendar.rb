class Calendar < ApplicationRecord
  include Accountable
  belongs_to :calendarable, polymorphic: true

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
    Calendars::Form.new resource, editable: editable
  end

  def time_zone
    calendarable.time_zone
  end
end
