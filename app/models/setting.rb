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

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "setable_type",
      "setable_id"
      # "key",
      # "priority",
      # "formating",
      # "value",
      # "created_at",
      # "updated_at"
    ]
    f = f - [
      "created_at",
      "updated_at"
    ] if model == self
    f
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

  def self.create_defaults_for_new(tenant)
    # create default settings for new tenant
    self.available_keys.each do |k|
      value, setable_type = case k[0]
      when "default_time_material_state"; [ "draft", "TimeMaterial" ]
      when "default_time_material_about"; [ I18n.t("time_material.default_assigned_about"), "TimeMaterial" ]
      when "default_time_material_hour_time"; [ "0", "TimeMaterial" ]
      when "default_time_material_minute_time"; [ "15", "TimeMaterial" ]
      when "default_time_material_rate"; [ "500", "TimeMaterial" ]
      when "default_time_material_over_time"; [ "0", "TimeMaterial" ]
      when "validate_time_material_done"; [ "false", "TimeMaterial" ]
      when "limit_time_to_quarters"; [ "false", "TimeMaterial" ]
      when "run"; [ "true", "BackgroundJob" ]
      else [ "true", "User" ]
      end
      self.create tenant: tenant, key: k[0], setable_type: setable_type, value: value
    end
  end

  def self.available_keys
    [
      [ "delegate_time_materials", I18n.t("settings.keys.delegate_time_materials") ],
      [ "run", I18n.t("settings.keys.run_background_jobs") ],
      [ "limit_time_to_quarters", I18n.t("settings.keys.limit_time_to_quarters") ],
      [ "default_time_material_state", I18n.t("settings.keys.default_time_material_state") ],
      [ "default_time_material_about", I18n.t("settings.keys.default_time_material_about") ],
      [ "default_time_material_hour_time", I18n.t("settings.keys.default_time_material_hour_time") ],
      [ "default_time_material_minute_time", I18n.t("settings.keys.default_time_material_minute_time") ],
      [ "default_time_material_rate", I18n.t("settings.keys.default_time_material_rate") ],
      [ "default_time_material_over_time", I18n.t("settings.keys.default_time_material_over_time") ],
      [ "allow_create_time_material", I18n.t("settings.keys.allow_create_time_material") ],
      [ "allow_create_product", I18n.t("settings.keys.allow_create_product") ],
      [ "allow_create_customer", I18n.t("settings.keys.allow_create_customer") ],
      [ "allow_create_project", I18n.t("settings.keys.allow_create_project") ],
      [ "validate_time_material_done", I18n.t("settings.keys.validate_time_material_done") ],
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
