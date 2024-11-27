class Setting < ApplicationRecord
  include Tenantable
  belongs_to :setable, polymorphic: true, optional: true

  scope :by_fulltext, ->(query) { where("key LIKE :query OR value LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_key, ->(key) { where("key LIKE ?", "%#{key}%") if key.present? }
  scope :by_priority, ->(priority) { where("priority LIKE ?", "%#{priority}%") if priority.present? }
  scope :by_value, ->(value) { where("value LIKE ?", "%#{value}%") if value.present? }

  validates :key, presence: true, uniqueness: { scope: [ :tenant_id, :setable_id ], message: I18n.t("settings.errors.messages.key_exist") }
  validates :value, presence: true
  # validates :setable_type, presence: true
  # validates :setable_id, numericality: { only_integer: true }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_key(flt["key"])
      .by_priority(flt["priority"])
      .by_value(flt["value"])
  rescue
    filter.destroy if filter
    all
  end

  def self.set_order(resources, field = :key, direction = :asc)
    resources.ordered(field, direction)
  end

  def self.form(resource:, editable: true)
    Settings::Form.new resource: resource, editable: editable, enctype: "multipart/form-data"
  end

  def name
    "#{key}"
  end

  def self.available_keys
    [
      [ "delegate_time_materials", I18n.t("settings.keys.delegate_time_materials") ],
      [ "show_all_time_material_posts", I18n.t("settings.keys.show_all_time_material_posts") ]
    ]
  end

  def self.available_tables
    [
      [ "BackgroundJob", I18n.t("settings.tables.background_jobs") ],
      [ "Customer", I18n.t("settings.tables.customers") ],
      [ "Dashboard", I18n.t("settings.tables.dashboards") ],
      [ "Invoice", I18n.t("settings.tables.invoices") ],
      [ "InvoiceItem", I18n.t("settings.tables.invoice_items") ],
      [ "Location", I18n.t("settings.tables.locations") ],
      [ "Product", I18n.t("settings.tables.products") ],
      [ "Project", I18n.t("settings.tables.projects") ],
      [ "Punche", I18n.t("settings.tables.punches") ],
      [ "PunchClock", I18n.t("settings.tables.punch_clocks") ],
      [ "Setting", I18n.t("settings.tables.settings") ],
      [ "Team", I18n.t("settings.tables.teams") ],
      [ "Tenant", I18n.t("settings.tables.tenants") ],
      [ "TimeMaterial", I18n.t("settings.tables.time_materials") ],
      [ "User", I18n.t("settings.tables.users") ]
    ]
  end
end
