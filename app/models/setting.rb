class Setting < ApplicationRecord
  include Tenantable
  belongs_to :setable, polymorphic: true, optional: true

  scope :by_fulltext, ->(query) { where("key LIKE :query OR value LIKE :query", query: "%#{query}%") if query.present? }
  scope :by_key, ->(key) { where("key LIKE ?", "%#{key}%") if key.present? }
  scope :by_priority, ->(priority) { where("priority LIKE ?", "%#{priority}%") if priority.present? }
  scope :by_value, ->(value) { where("value LIKE ?", "%#{value}%") if value.present? }


  scope :for_key, ->(k) { where(key: k.to_s) }
  scope :allowed, -> { where(value: %w[1 true]) }
  scope :denied,  -> { where(value: %w[0 false]) }

  validates :tenant, :key, :value, presence: true
  validates :key, presence: true, uniqueness: { scope: [ :tenant_id, :setable_type, :setable_id ], message: I18n.t("settings.errors.messages.key_exist") }
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
      "session_timeout" => "text",
      "run" => "boolean",
      "limit_time_to_quarters" => "boolean",
      "default_time_material_date" => "text",
      "default_time_material_state" => "option",
      "default_time_material_about" => "text",
      "default_time_material_hour_time" => "text",
      "default_time_material_minute_time" => "text",
      "default_time_material_rate" => "text",
      # "default_time_material_over_time" => "boolean",
      "add_time_materials" => "boolean",
      "add_customers" => "boolean",
      "add_projects" => "boolean",
      "add_products" => "boolean",
      "delegate_time_materials" => "boolean",
      "see_mileage_tab" => "boolean",
      "use_customers" => "boolean",
      "use_projects" => "boolean",
      "do_invoicing" => "boolean",
      "edit_hourly_rate" => "boolean",
      "edit_overtime" => "boolean",
      "add_tags_on_time_material" => "boolean",
      "add_comments_on_time_material" => "boolean",
      "see_material_tab" => "boolean",
      "import_customers_only" => "boolean",
      "sync_with_erp" => "boolean",
      "pull_customers" => "boolean",
      "pull_products" => "boolean",
      "pull_invoices" => "boolean",
      "pull_provided_services" => "boolean",
      "validate_time_material_done" => "boolean",
      "show_all_time_material_posts" => "boolean",
      "show_stop_button" => "boolean",
      "fill_play_time_in_time_fields" => "boolean",
      "show_time_stats" => "boolean"
    }
  end

  def self.setting_options
    {
      "default_time_material_state" => {
        "draft" => I18n.t("time_material.states.draft"),
        "done" => I18n.t("time_material.states.done")
      },
      "default_time_material_rate" => {
        "750,75" => "750,75",
        "500,00" => "500,00",
        "250,00" => "250,00"
      }
    }
  end

  # Create default settings for a new tenant
  # This method initializes default settings for a new tenant.
  #
  # @param tenant [Tenant] The tenant for which to create default settings.
  #

  def self.create_defaults_for_new(tenant)
    # create default settings for new tenant
    self.available_keys.each do |k|
      value, setable_type = case k[0]
      when "default_time_material_state";         [ "done", "TimeMaterial" ]
      when "default_time_material_date";          [ "Time.current.to_date", "TimeMaterial" ]
      when "default_time_material_about";         [ I18n.t("time_material.default_assigned_about"), "TimeMaterial" ]
      when "default_time_material_hour_time";     [ "0", "TimeMaterial" ]
      when "default_time_material_minute_time";   [ "15", "TimeMaterial" ]
      # when "default_time_material_rate";          [ "500.00", "TimeMaterial" ]
      # when "default_time_material_over_time"; [ "0", "TimeMaterial" ]
      when "validate_time_material_done";         [ "false", "TimeMaterial" ]
      when "limit_time_to_quarters";              [ "false", "TimeMaterial" ]
      when "run";                                 [ "true", "BackgroundJob" ]
      when "see_mileage_tab";                     [ "false", "TimeMaterial" ]
      when "see_material_tab";                    [ "false", "TimeMaterial" ]
      when "add_tags_on_time_material";           [ "false", "TimeMaterial" ]
      when "add_comments_on_time_material";       [ "false", "TimeMaterial" ]
      when "session_timeout";                     [ "7.days", nil ]
      else                                        [ "true", "TimeMaterial" ]
      end
      self.create tenant: tenant, key: k[0], setable_type: setable_type, value: value
    end
  end

  def self.available_keys
    [
      [ "delegate_time_materials", I18n.t("settings.keys.delegate_time_materials") ],
      [ "run", I18n.t("settings.keys.run_background_jobs") ],
      [ "session_timeout", I18n.t("settings.keys.session_timeout") ],
      [ "limit_time_to_quarters", I18n.t("settings.keys.limit_time_to_quarters") ],
      [ "default_time_material_date", I18n.t("settings.keys.default_time_material_date") ],
      [ "default_time_material_state", I18n.t("settings.keys.default_time_material_state") ],
      [ "default_time_material_about", I18n.t("settings.keys.default_time_material_about") ],
      [ "default_time_material_hour_time", I18n.t("settings.keys.default_time_material_hour_time") ],
      [ "default_time_material_minute_time", I18n.t("settings.keys.default_time_material_minute_time") ],
      [ "default_time_material_rate", I18n.t("settings.keys.default_time_material_rate") ],
      # [ "default_time_material_over_time", I18n.t("settings.keys.default_time_material_over_time") ],
      [ "add_time_materials", I18n.t("settings.keys.add_time_material") ],
      [ "add_customers", I18n.t("settings.keys.add_customer") ],
      [ "add_projects", I18n.t("settings.keys.add_project") ],
      [ "add_products", I18n.t("settings.keys.add_product") ],
      [ "delegate_time_materials", I18n.t("settings.keys.delegate_time_materials") ],
      [ "see_mileage_tab", I18n.t("settings.keys.see_mileage_tab") ],
      [ "use_customers", I18n.t("settings.keys.use_customers") ],
      [ "use_projects", I18n.t("settings.keys.use_projects") ],
      [ "do_invoicing", I18n.t("settings.keys.do_invoicing") ],
      [ "edit_hourly_rate", I18n.t("settings.keys.edit_hourly_rate") ],
      [ "edit_overtime", I18n.t("settings.keys.edit_overtime") ],
      [ "add_tags_on_time_material", I18n.t("settings.keys.add_tags_on_time_material") ],
      [ "add_comments_on_time_material", I18n.t("settings.keys.add_comments_on_time_material") ],
      [ "see_material_tab", I18n.t("settings.keys.see_material_tab") ],
      [ "import_customers_only", I18n.t("settings.keys.import_customers_only") ], # only pull from server - not push (new)
      [ "sync_with_erp", I18n.t("settings.keys.sync_with_erp") ],
      [ "pull_customers", I18n.t("settings.keys.pull_customers") ],
      [ "pull_products", I18n.t("settings.keys.pull_products") ],
      [ "pull_invoices", I18n.t("settings.keys.pull_invoices") ],
      [ "pull_provided_services", I18n.t("settings.keys.pull_provided_services") ],   # pull all - customers, products, invoices, more
      [ "validate_time_material_done", I18n.t("settings.keys.validate_time_material_done") ],
      [ "show_all_time_material_posts", I18n.t("settings.keys.show_all_time_material_posts") ],
      [ "show_stop_button", I18n.t("settings.keys.show_stop_button") ],
      [ "fill_play_time_in_time_fields", I18n.t("settings.keys.fill_play_time_in_time_fields") ],
      [ "show_time_stats", I18n.t("settings.keys.show_time_stats") ]
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

  # settings will be the 'default' settings for the resource - be it a specific resource or a class
  # If a resource is provided, it will use the resource's settings, otherwise it will use the class's settings
  #
  # @param settings [Hash] The settings to be applied.
  # @param resource [Object, nil] The resource for which the settings are being applied.
  # @return [Hash] The settings with their values and IDs.
  #
  def self.get_settings(settings = {}, resource: nil)
    resource_settings = resource.nil? ? Current.get_tenant.settings : resource.settings
    settings.each do |key, setting|
      found = false
      if resource.is_a?(Class)
        stype = resource.to_s
        sid = nil
      else
        stype = resource&.class&.to_s
        sid = resource&.id
      end
      resource_settings.filter { |r| r.key == key }.each do |r|
        found = true
        settings[key]["id"] = r.id
        settings[key]["value"] = r.value
        settings[key]["object"] = r
      end
      unless found
        obj = Setting.create(tenant: Current.get_tenant, key: key, setable_type: stype, setable_id: sid, value: setting["value"])
        settings[key] = settings[key].merge({
          "id" => obj.id,
          "value" => setting["value"],
          "object" => obj
        })
      end
    end
    settings
  end

  # General settings for the application
  # This method returns a hash of settings with their types and default values.
  # It can be used to initialize or display settings in the application.
  #
  # @return [Hash] A hash containing the general settings for the application.
  #
  def self.general_settings(resource: nil)
    self.get_settings({
      "session_timeout" => { "type" => "text", "value" => "7.days" },
      "run" => { "type" => "boolean", "value" => "0", "setable_type" => "BackgroundJob", "setable_id" => nil },
      "import_customers_only" => { "type" => "boolean", "value" => "1" },
      "sync_with_erp" => { "type" => "boolean", "value" => "1" }
    }, resource: resource)
  end

  def self.time_material_settings(resource: nil)
    # return self.get_settings(DEFAULT_TIME_SETTINGS, resource:) unless Rails.env.test?
    build_settings_for(resource:, keys: DEFAULT_TIME_SETTINGS, klass_name: klass_for(resource))
  end
  def self.team_settings(resource: nil)
    # return self.get_settings(DEFAULT_TIME_SETTINGS, resource:) unless Rails.env.test?
    build_settings_for(resource:, keys: DEFAULT_TIME_SETTINGS, klass_name: klass_for(resource))
  end
  def self.user_settings(resource: nil)
    # return self.get_settings(DEFAULT_TIME_SETTINGS, resource:) unless Rails.env.test?
    build_settings_for(resource:, keys: DEFAULT_TIME_SETTINGS, klass_name: klass_for(resource))
  end

  def self.customer_settings(resource: nil)
    self.get_settings({
      "sync_with_erp" => { "type" => "boolean", "value" => "true" },
      "pull_customers" => { "type" => "boolean", "value" => "1" },
      "add_customers" => { "type" => "boolean", "value" => "true" },
      "use_customers" => { "type" => "boolean", "value" => "true" }
    })
  end
  def self.project_settings(resource: nil)
    self.get_settings({
      "add_projects" => { "type" => "boolean", "value" => "true" },
      "use_projects" => { "type" => "boolean", "value" => "true" }
    }, resource:)
  end
  def self.product_settings(resource: nil)
    self.get_settings({
      "add_products" => { "type" => "boolean", "value" => "true" },
      "use_products" => { "type" => "boolean", "value" => "true" },
      "pull_products" => { "type" => "boolean", "value" => "1" }
    }, resource:)
  end
  def self.erp_integration_settings(resource: nil)
    self.get_settings({
      "import_customers_only" => { "type" => "boolean", "value" => "true" },
      "pull_provided_services" => { "type" => "boolean", "value" => "true" },
      "sync_with_erp" => { "type" => "boolean", "value" => "true" }
    }, resource:)
  end

  def self.permissions_settings(resource: nil)
    self.get_settings({}, resource:)
  end

  def self.klass_for(resource)
    return "User" if resource.is_a?(User) || resource == User
    return "Team" if resource.is_a?(Team) || resource == Team
    return "TimeMaterial" if resource.is_a?(TimeMaterial) || resource == TimeMaterial
    resource&.class&.name || "TimeMaterial"
  end

  private_class_method :klass_for
  DEFAULT_TIME_SETTINGS = {
      "delegate_time_materials" => { "type" => "boolean", "value" => "true" },
      "limit_time_to_quarters" => { "type" => "boolean", "value" => "false" },
      "default_time_material_date" => { "type" => "text", "value" => "Time.current.to_date" },
      "default_time_material_state" => { "type" => "option", "value" =>  "done", "options" => {
        "draft" => I18n.t("time_material.states.draft"),
        "active" => I18n.t("time_material.states.active"),
        "paused" => I18n.t("time_material.states.paused"),
        "done" => I18n.t("time_material.states.done")
        }
      },
      "default_time_material_about" => { "type" => "text", "value" => I18n.t("time_material.default_assigned_about") },
      "default_time_material_hour_time" => { "type" => "text", "value" => "0" },
      "default_time_material_minute_time" => { "type" => "text", "value" => "15" },
      "default_time_material_rate" => { "type" => "text", "value" => "750,00" },
      "default_time_material_over_time" => { "type" => "boolean", "value" => "true" },
      "add_time_materials" => { "type" => "boolean", "value" => "true" },
      "see_mileage_tab" => { "type" => "boolean", "value" => "false" },
      "use_customers" => { "type" => "boolean", "value" => "true" },
      "add_customers" => { "type" => "boolean", "value" => "true" },
      "use_projects" => { "type" => "boolean", "value" => "true" },
      "add_projects" => { "type" => "boolean", "value" => "true" },
      "do_invoicing" => { "type" => "boolean", "value" => "true" },
      "edit_hourly_rate" => { "type" => "boolean", "value" => "true" },
      "edit_overtime" => { "type" => "boolean", "value" => "true" },
      "add_tags_on_time_material" => { "type" => "boolean", "value" => "true" },
      "add_comments_on_time_material" => { "type" => "boolean", "value" => "false" },
      "see_material_tab" => { "type" => "boolean", "value" => "true" },
      "validate_time_material_done" => { "type" => "boolean", "value" => "true" },
      "show_all_time_material_posts" => { "type" => "boolean", "value" => "true" },
      "show_stop_button" => { "type" => "boolean", "value" => "true" },
      "fill_play_time_in_time_fields" => { "type" => "boolean", "value" => "true" },
      "show_time_stats" => { "type" => "boolean", "value" => "true" }
    }

  # Helpers

  def self.build_settings_for(resource:, keys:, klass_name:)
    tenant = Current.get_tenant || (resource.respond_to?(:tenant) ? resource.tenant : nil)
    raise ArgumentError, "tenant required" unless tenant

    setable_type, setable_id =
      if resource.nil?
        [ nil, nil ]                                 # tenant-level
      elsif resource.is_a?(Class)
        [ klass_name, nil ]                          # class-level
      else
        [ klass_name, resource.id ]                  # instance-level
      end

    # Ensure one row per key at the chosen level. New rows use DEFAULT values,
    # existing rows are preserved.
    rs = resource.nil? ? tenant.settings : resource.settings

    mapped = {}
    keys.each do |key, default_value|
      Rails.logger.info "Looking for setting '#{key}' for #{setable_type}(#{setable_id || 'nil'})"
      rec = rs.find { |s| s.key == key && s.setable_type == setable_type && s.setable_id == setable_id }
      if rec.present?
        mapped[key] = default_value.merge({
          "id" => rec.id,
          "object" => rec,
          "value" => rec.value
        })
        next
      end

      Rails.logger.info "Setting '#{key}' not found for #{setable_type}(#{setable_id || 'nil'}); creating with default value."
      # new record
      mapped[key] = default_value.merge({
        "id" => "0",
        "object" => Setting.new(tenant: tenant, setable_type: setable_type, setable_id: setable_id, key: key, value: default_value["value"]),
        "value" => default_value["value"]
      })
    end
    mapped
    # to_result_map(mapped, keys.keys)
  end

  private_class_method :build_settings_for

  def self.to_result_map(relation, keys)
    # Return a Hash: key => {"object" => rec, "id" => rec.id, "value" => rec.value}
    records_by_key = relation.index_by(&:key)
    keys.each_with_object({}) do |k, acc|
      rec = records_by_key[k]
      acc[k] = {
        "object" => rec,
        "id"     => rec&.id,
        "value"  => rec&.value
      }
    end
  end
  private_class_method :to_result_map
end
