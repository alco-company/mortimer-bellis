class Event < ApplicationRecord
  include Accountable
  belongs_to :calendar

  has_many_attached :files

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
