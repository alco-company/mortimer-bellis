class Holiday < ApplicationRecord
  scope :by_tenant, ->() { all }

  scope :by_fulltext, ->(query) { where("name LIKE :query OR countries LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_from_date, ->(from_date) { where("from_date >= ?", from_date) if from_date.present? }
  scope :by_to_date, ->(to_date) { where("to_date <= ?", to_date) if to_date.present? }
  scope :by_country, ->(country) { where("countries LIKE ?", "%#{country}%") if country.present? }
  scope :order_by_number, ->(field) { order("length(#{field}) DESC, #{field} DESC") }

  validates :name, presence: true

  def self.today?(dt)
    today(dt).any?
  end

  def self.today(dt)
    where(from_date: ..dt).and(where(to_date: dt..))
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_name(flt["name"])
      .by_from_date((Date.parse(flt["from_date"]) rescue nil))
      .by_to_date((Date.parse(flt["to_date"]) rescue nil))
      .by_country(flt["countries"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource:, editable: true)
    Holidays::Form.new resource: resource, editable: editable, enctype: "multipart/form-data"
  end

  private
end
