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

  def label
    I18n.t("settings.keys.#{key}", default: key.humanize)
  end

  def description
    I18n.t("settings.descriptions.#{key}", default: key.humanize)
  end

  def type
    Setting.setting_types[key] || "text"
  end

  def self.setting_types
    {
      "delegate_time_materials" => "boolean",
      "run" => "boolean",
      "limit_time_to_quarters" => "boolean",
      "default_time_material_date" => "date",
      "default_time_material_state" => "option",
      "default_time_material_about" => "text",
      "default_time_material_hour_time" => "text",
      "default_time_material_minute_time" => "text",
      "default_time_material_rate" => "text",
      # "default_time_material_over_time" => "boolean",
      "allow_create_time_material" => "boolean",
      "allow_create_product" => "boolean",
      "allow_create_customer" => "boolean",
      "allow_create_project" => "boolean",
      "allow_comments_on_time_material" => "boolean",
      "import_customers_only" => "boolean",
      "sync_with_erp" => "boolean",
      "validate_time_material_done" => "boolean",
      "show_all_time_material_posts" => "boolean"
    }
  end

  def self.create_defaults_for_new(tenant)
    # create default settings for new tenant
    self.available_keys.each do |k|
      value, setable_type = case k[0]
      when "default_time_material_state";         [ "draft", "TimeMaterial" ]
      when "default_time_material_date";          [ "Time.current.to_date", "TimeMaterial" ]
      when "default_time_material_about";         [ I18n.t("time_material.default_assigned_about"), "TimeMaterial" ]
      when "default_time_material_hour_time";     [ "0", "TimeMaterial" ]
      when "default_time_material_minute_time";   [ "15", "TimeMaterial" ]
      # when "default_time_material_rate"; [ "500", "TimeMaterial" ]
      # when "default_time_material_over_time"; [ "0", "TimeMaterial" ]
      when "validate_time_material_done";         [ "false", "TimeMaterial" ]
      when "limit_time_to_quarters";              [ "false", "TimeMaterial" ]
      when "run";                                 [ "true", "BackgroundJob" ]
      else                                        [ "true", "User" ]
      end
      self.create tenant: tenant, key: k[0], setable_type: setable_type, value: value
    end
  end

  def self.available_keys
    [
      [ "delegate_time_materials", I18n.t("settings.keys.delegate_time_materials") ],
      [ "run", I18n.t("settings.keys.run_background_jobs") ],
      [ "limit_time_to_quarters", I18n.t("settings.keys.limit_time_to_quarters") ],
      [ "default_time_material_date", I18n.t("settings.keys.default_time_material_date") ],
      [ "default_time_material_state", I18n.t("settings.keys.default_time_material_state") ],
      [ "default_time_material_about", I18n.t("settings.keys.default_time_material_about") ],
      [ "default_time_material_hour_time", I18n.t("settings.keys.default_time_material_hour_time") ],
      [ "default_time_material_minute_time", I18n.t("settings.keys.default_time_material_minute_time") ],
      # [ "default_time_material_rate", I18n.t("settings.keys.default_time_material_rate") ],
      # [ "default_time_material_over_time", I18n.t("settings.keys.default_time_material_over_time") ],
      [ "allow_create_time_material", I18n.t("settings.keys.allow_create_time_material") ],
      [ "allow_create_product", I18n.t("settings.keys.allow_create_product") ],
      [ "allow_create_customer", I18n.t("settings.keys.allow_create_customer") ],
      [ "allow_create_project", I18n.t("settings.keys.allow_create_project") ],
      [ "allow_comments_on_time_material", I18n.t("settings.keys.allow_comments_on_time_material") ],
      [ "import_customers_only", I18n.t("settings.keys.import_customers_only") ],
      [ "sync_with_erp", I18n.t("settings.keys.sync_with_erp") ],
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

  def self.get_settings(settings = {})
    tenant_settings = Current.get_tenant.settings
    settings.each do |key, setting|
      found = false
      tenant_settings.filter { |r| r.key == key }.each do |r|
        found = true
        settings[key]["id"] = r.id
        settings[key]["value"] = r.value
        settings[key]["object"] = r
      end
      settings[key] = settings[key].merge({
        "id" => "0",
        "value" => setting["value"],
        "object" => Setting.create(tenant: Current.get_tenant, key: key, setable_type: setting["setable_type"], setable_id: setting["setable_id"], value: setting["value"])
      }) unless found
    end
    settings
  end

  # General settings for the application
  # This method returns a hash of settings with their types and default values.
  # It can be used to initialize or display settings in the application.
  #
  # @return [Hash] A hash containing the general settings for the application.
  #
  def self.general_settings
    self.get_settings({
      "delegate_time_materials" => { "type" => "boolean", "value" => "1" },
      "run" => { "type" => "boolean", "value" => "0", "setable_type" => "BackgroundJob", "setable_id" => nil },
      "limit_time_to_quarters" => { "type" => "boolean", "value" => "1" },
      "default_time_material_date" => { "type" => "date", "value" => Time.current.to_date },
      "default_time_material_state" => { "type" => "select", "value" =>  "draft", "options" => { "draft" => I18n.t("time_material.states.draft"), "done" => I18n.t("time_material.states.done") } },
      "default_time_material_about" => { "type" => "text", "value" => I18n.t("time_material.default_assigned_about") },
      "default_time_material_hour_time" => { "type" => "text", "value" => "0" },
      "default_time_material_minute_time" => { "type" => "text", "value" => "15" },
      "default_time_material_rate" => { "type" => "text", "value" => "750,75" },
      "default_time_material_over_time" => { "type" => "boolean", "value" => "1" },
      "allow_create_time_material" => { "type" => "boolean", "value" => "1" },
      "allow_create_product" => { "type" => "boolean", "value" => "1" },
      "allow_create_customer" => { "type" => "boolean", "value" => "1" },
      "allow_create_project" => { "type" => "boolean", "value" => "1" },
      "allow_comments_on_time_material" => { "type" => "boolean", "value" => "1" },
      "import_customers_only" => { "type" => "boolean", "value" => "1" },
      "sync_with_erp" => { "type" => "boolean", "value" => "1" },
      "validate_time_material_done" => { "type" => "boolean", "value" => "1" },
      "show_all_time_material_posts" => { "type" => "boolean", "value" => "1" }
    })
  end
  def self.time_material_settings
    self.get_settings({
      "delegate_time_materials" => { "type" => "boolean", "value" => true },
      "limit_time_to_quarters" => { "type" => "boolean", "value" => true },
      "default_time_material_date" => { "type" => "date", "value" => Time.current.to_date },
      "default_time_material_state" => { "type" => "select", "value" =>  "draft", "options" => { "draft" => I18n.t("time_material.states.draft"), "done" => I18n.t("time_material.states.done") } },
      "default_time_material_about" => { "type" => "text", "value" => I18n.t("time_material.default_assigned_about") },
      "default_time_material_hour_time" => { "type" => "text", "value" => "0" },
      "default_time_material_minute_time" => { "type" => "text", "value" => "15" },
      "default_time_material_rate" => { "type" => "boolean", "value" => "750,75" },
      "default_time_material_over_time" => { "type" => "boolean", "value" => true },
      "allow_comments_on_time_material" => { "type" => "boolean", "value" => true },
      "validate_time_material_done" => { "type" => "boolean", "value" => true }
    })
  end
  def self.customer_settings
    self.get_settings({
      "delegate_time_materials" => { "type" => "boolean", "value" => true },
      "run" => { "type" => "boolean", "value" => true },
      "limit_time_to_quarters" => { "type" => "boolean", "value" => true },
      "default_time_material_date" => { "type" => "date", "value" => Time.current.to_date },
      "default_time_material_state" => { "type" => "select", "value" =>  "draft", "options" => { "draft" => I18n.t("time_material.states.draft"), "done" => I18n.t("time_material.states.done") } },
      "default_time_material_about" => { "type" => "text", "value" => I18n.t("time_material.default_assigned_about") },
      "default_time_material_hour_time" => { "type" => "text", "value" => "0" },
      "default_time_material_minute_time" => { "type" => "text", "value" => "15" },
      "default_time_material_rate" => { "type" => "boolean", "value" => "750,75" },
      "default_time_material_over_time" => { "type" => "boolean", "value" => true },
      "allow_create_time_material" => { "type" => "boolean", "value" => true },
      "allow_create_product" => { "type" => "boolean", "value" => true },
      "allow_create_customer" => { "type" => "boolean", "value" => true },
      "allow_create_project" => { "type" => "boolean", "value" => true },
      "allow_comments_on_time_material" => { "type" => "boolean", "value" => true },
      "import_customers_only" => { "type" => "boolean", "value" => true },
      "sync_with_erp" => { "type" => "boolean", "value" => true },
      "validate_time_material_done" => { "type" => "boolean", "value" => true },
      "show_all_time_material_posts" => { "type" => "boolean", "value" => true }
    })
  end
  def self.project_settings
    self.get_settings({
      "allow_create_project" => { "type" => "boolean", "value" => true }
    })
  end
  def self.product_settings
    self.get_settings({
      "allow_create_product" => { "type" => "boolean", "value" => true }
    })
  end
  def self.team_settings
  end
  def self.user_settings
    self.get_settings({
      "delegate_time_materials" => { "type" => "boolean", "value" => true },
      "limit_time_to_quarters" => { "type" => "boolean", "value" => true },
      "default_time_material_date" => { "type" => "date", "value" => Time.current.to_date },
      "default_time_material_state" => { "type" => "select", "value" =>  "draft", "options" => { "draft" => I18n.t("time_material.states.draft"), "done" => I18n.t("time_material.states.done") } },
      "default_time_material_about" => { "type" => "text", "value" => I18n.t("time_material.default_assigned_about") },
      "default_time_material_hour_time" => { "type" => "text", "value" => "0" },
      "default_time_material_minute_time" => { "type" => "text", "value" => "15" },
      "default_time_material_rate" => { "type" => "boolean", "value" => "750,75" },
      "default_time_material_over_time" => { "type" => "boolean", "value" => true },
      "allow_create_time_material" => { "type" => "boolean", "value" => true },
      "allow_create_product" => { "type" => "boolean", "value" => true },
      "allow_create_customer" => { "type" => "boolean", "value" => true },
      "allow_create_project" => { "type" => "boolean", "value" => true },
      "allow_comments_on_time_material" => { "type" => "boolean", "value" => true },
      "show_all_time_material_posts" => { "type" => "boolean", "value" => true }
    })
  end
  def self.erp_integration_settings
    self.get_settings({
      "import_customers_only" => { "type" => "boolean", "value" => true },
      "sync_with_erp" => { "type" => "boolean", "value" => true }
    })
  end
  def self.permissions_settings
    self.get_settings({
      "validate_time_material_done" => { "type" => "boolean", "value" => true },
      "show_all_time_material_posts" => { "type" => "boolean", "value" => true }
    })
  end
end
