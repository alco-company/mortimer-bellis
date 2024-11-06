class Dashboard < ApplicationRecord
  include Tenantable

  scope :by_fulltext, ->(query) { where("feed LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_feed, ->(feed) { where("feed LIKE ?", "%#{feed}%") if feed.present? }

  validates :feed, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("dashboards.errors.messages.feed_exist") }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_feed(flt["feed"])
  rescue
    filter.destroy if filter
    all
  end

  def self.set_order(resources, field = :feed, direction = :asc)
    resources.ordered(field, direction)
  end

  def name
    feed
  end

  def self.form(resource:, editable: true)
    Dashboards::Form.new resource: resource, editable: editable
  end
end
