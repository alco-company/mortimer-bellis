#
# ex of filter form output
#
# {"date"=>{"attribute"=>"paused_at", "fixed_range"=>"this_week", "custom_from"=>"", "custom_to"=>""},
#  "customer"=>
#   {"name"=>"like|mosegrisen",
#    "street"=>"|",
#    "zipcode"=>"|",
#    "city"=>"|",
#    "phone"=>"|",
#    "email"=>"|",
#    "vat_number"=>"|",
#    "ean_number"=>"|",
#    "external_reference"=>"|",
#    "is_person"=>"|",
#    "is_debitor"=>"|",
#    "is_creditor"=>"|",
#    "webpage"=>"|",
#    "att_person"=>"|",
#    "payment_condition_type"=>"|",
#    "payment_condition_number_of_days"=>"|"},
#  "project"=>{"name"=>"|", "state"=>"|", "budget"=>"|", "is_billable"=>"|", "is_separate_invoice"=>"|", "hourly_rate"=>"|", "priority"=>"|", "estimated_minutes"=>"|", "actual_minutes"=>"|"},
#  "product"=>
#   {"name"=>"|", "product_number"=>"|", "quantity"=>"|", "unit"=>"|", "account_number"=>"|", "base_amount_value"=>"|", "base_amount_value_incl_vat"=>"|", "total_amount"=>"|", "total_amount_incl_vat"=>"|", "external_reference"=>"|"},
#  "time_material"=>
#   {"about"=>"|",
#    "customer_name"=>"|",
#    "project_name"=>"|",
#    "product_name"=>"|",
#    "quantity"=>"|",
#    "rate"=>"|",
#    "discount"=>"|",
#    "state"=>"|",
#    "is_invoice"=>"|",
#    "is_free"=>"|",
#    "is_offer"=>"|",
#    "is_separate"=>"|",
#    "comment"=>"|",
#    "unit_price"=>"|",
#    "unit"=>"|",
#    "time_spent"=>"|",
#    "over_time"=>"|"},
#  "scope"=>{"user"=>"my_team", "named_users_teams"=>""},
#  "customer_id"=>"829",
#  "customer_name"=>"",
#  "project_id"=>"56",
#  "project_name"=>"11",
#  "product_id"=>"",
#  "product_name"=>""
# }


class Filters::Form < ApplicationForm
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::DOMID

  # def initialize(filter_form:, url:)
  #   @filter_form = filter_form
  #   @url = url
  # end

  attr_accessor :resource, :cancel_url, :title, :edit_url, :api_key, :model, :fields, :params, :url, :filter_form, :filtered_model

  def initialize(resource:, url:, filter_form:, params:, **options)
    options[:data] ||= { form_target: "form", controller: "filter" }
    options[:class] = "mort-form"
    super(resource: resource, **options)
    @resource = @model = resource
    @filter_form = filter_form
    @filtered_model = filter_form.classify.constantize rescue resource.view&.classify&.constantize
    @params = params
    @fields = options[:fields] || []
    @fields = @fields.any? ? @fields : filtered_model&.attribute_types&.keys || []
    @url = url
  end

  def view_template
    div(data_controller: "filter") do
      row field(:url).hidden(value: @url)
      row field(:filter_form).hidden(value: @filter_form)
      h3(class: "text-lg font-medium") { I18n.t("filters.filter_for", model: I18n.t("#{filtered_model.to_s.underscore.pluralize}.list.title")) }
      div do
        tabs
        tabs_content
      end
    end
  end

  def tabs
    div(class: "sm:hidden") do
      label(for: "tabs", class: "sr-only") { "Select a tab" }
      select(
        id: "tabs",
        name: "tabs",
        data: { action: "filter#selectTab" },
        class:
          "block mt-2 w-full rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-sky-200 focus:outline-hidden focus:ring-sky-200 sm:text-sm"
      ) do
        option(data: { id: "dates" }, selected: "selected")  { I18n.t("filters.tabs.titles.date") }
        option(data: { id: "fields" }) { I18n.t("filters.tabs.titles.field") }
        option(data: { id: "scopes" }) { I18n.t("filters.tabs.titles.scope") }
        option(data: { id: "help" }) { I18n.t("filters.tabs.titles.help") }
      end
    end
    div(class: "hidden sm:block") do
      div(class: "border-b border-slate-100") do
        nav(class: "-mb-px flex space-x-8", aria_label: "Tabs") do
          comment do
            %(Current: "border-sky-200 text-sky-200", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
          end
          a(
            href: "#",
            data_id: "dates",
            data_action: "filter#selectTab",
            data_filter_target: "tabtitle",
            class:
              "whitespace-nowrap border-b-2 border-sky-100 px-1 py-4 text-sm font-medium text-sky-600 hover:border-gray-300 hover:text-gray-700",
            aria_current: "page"
          ) { I18n.t("filters.tabs.titles.date") }
          a(
            href: "#",
            data_id: "fields",
            data_action: "filter#selectTab",
            data_filter_target: "tabtitle",
            class:
              "whitespace-nowrap border-b-2 border-transparent px-1 py-4 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"
          ) { I18n.t("filters.tabs.titles.field") }
          a(
            href: "#",
            data_id: "scopes",
            data_action: "filter#selectTab",
            data_filter_target: "tabtitle",
            class:
              "whitespace-nowrap border-b-2 border-transparent px-1 py-4 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"
          ) { I18n.t("filters.tabs.titles.scope") }
          a(
            href: "#",
            data_id: "introduction",
            data_action: "filter#selectTab",
            data_filter_target: "tabtitle",
            class:
              "whitespace-nowrap border-b-2 border-transparent px-1 py-4 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"
          ) { I18n.t("filters.tabs.titles.help") }
        end
      end
    end
  end

  def tabs_content
    dates_tab
    fields_tab
    scopes_tab
    div(class: "hidden", data_filter_target: "tabs", id: "introduction") do
      h3(class: "mt-4 font-medium") { I18n.t("filters.help.title") }
      p(class: "my-2") { I18n.t("filters.help.description") }
      #
      # 2025/1/22: preset filters will have to wait for the next version
      #
      # p(class: "my-2") { I18n.t("filters.help.presets") }
      # ul(class: "my-2") do
      #   Current.user.preset_filter.each do |preset|
      #     li do
      #       button_to preset.name,
      #         resources_url(
      #           filter: {
      #             filter_form: preset,
      #           }
      #         ),
      #         class: "mort-link-primary"
      #     end
      #   end
      # end
    end
  end

  # resource.filter["date"] = {"attribute"=>"paused_at", "fixed_range"=>"this_week", "custom_from"=>"", "custom_to"=>""},
  def dates_tab
    div(class: "", data_filter_target: "tabs", id: "dates") do
      div do
        date_attr = resource.filter["date"] ? resource.filter["date"]["attribute"] : ""
        button(class: "mort-btn-primary mt-4", data: { action: "click->filter#clearDate" }) { I18n.t("filters.drop_date_filtering") }
        div(class: "mort-field") do
          label(class: "mr-2 text-nowrap text-gray-400", for: "") do
            I18n.t("filters.period.title")
          end
          select(name: "filter[date][attribute]", id: "", class: "mort-form-select mt-2") do
            filtered_model&.columns&.each do |col|
              next if col.name =~ /^odo/
              option(value: col.name, selected: date_attr == col.name) { I18n.t("activerecord.attributes.#{filtered_model.to_s.underscore}.#{col.name}") } if %w[ date datetime time ].include? col.type.to_s
              # option(value: col.name, selected: date_attr == col.name) { I18n.t("activerecord.attributes.#{filtered_model.to_s.underscore}.#{col.name}") } if col.name =~ /^date/
            end
          end
        end
        fixed_range_attr = resource.filter["date"] ? resource.filter["date"]["fixed_range"] : ""
        div(class: "mort-field") do
          label(class: "mr-2 text-gray-400", for: "") { I18n.t("filters.period.fixed_range") }
          input(type: "hidden", id: "filter_date_fixed_range", name: "filter[date][fixed_range]", value: fixed_range_attr)
          ul(class: "mt-1 px-2 w-full") do
            %w[ today yesterday this_week last_week this_month last_month last_3_months last_year ].each do |range|
              li(class: "rounded-md hover:bg-gray-50 leading-6 text-sm w-full my-1 py-2 px-3 cursor-pointer", data: { filter_target: "dateRange", action: "click->filter#setDate", range: range }) { I18n.t("filters.period.#{range}") }
            end
          end
        end
        div(class: "px-3 mt-3") do
          h3(class: "text-gray-400") { I18n.t("filters.period.custom_range") }
          div(class: "grid items-center") do
            custom_from_attr = resource.filter["date"] ? resource.filter["date"]["custom_from"] : ""
            div(class: "mort-field my-1 flex columns-2 items-center") do
              label(class: "mr-2 grow", for: "") { "from" }
              input(type: "date", id: "filter_date_custom_from", name: "filter[date][custom_from]", value: custom_from_attr, class: "mort-form-text w-3/4", data: { action: "blur->filter#clearFixedRange" })
            end
            custom_to_attr = resource.filter["date"] ? resource.filter["date"]["custom_to"] : ""
            div(class: "mort-field my-0 flex columns-2 items-center") do
              label(class: "mr-2 grow", for: "") { "to" }
              input(type: "date", id: "filter_date_custom_to", name: "filter[date][custom_to]", value: custom_to_attr, class: "mort-form-text w-3/4", data: { action: "blur->filter#clearFixedRange" })
            end
          end
        end
      end
    end
  end

  def fields_tab
    div(class: "hidden", data_filter_target: "tabs", id: "fields") do
      ul(role: "list", class: "-mx-2 mt-2 space-y-1") do
        # 24/1/2025 TODO allow user to filter on has_many associations (the _hm)
        bt, _hm = filtered_model&.associations || [ [], [] ]
        bt.each do |assoc|
          list_association_fields(assoc)
        end
        list_fields(filtered_model)
      end
    end
  end

  def scopes_tab
    div(class: "hidden mt-4", data_filter_target: "tabs", id: "scopes") do
      fieldset do
        legend(class: "text-sm font-semibold leading-6 text-gray-900") { I18n.t("filters.scope.user.title") }
        p(class: "mt-1 text-sm leading-6 text-gray-600") { I18n.t("filters.scope.user.description") }
        user_scope
      end
      bt, _hm = filtered_model&.associations || [ [], [] ]
      bt.each do |assoc|
        association_scope(assoc)
        # case 0
        # when assoc.to_s.downcase =~ /customer/
        #   div(class: "mort-field", id: "filter_customer_id") do
        #     row field(:customer_id).lookup(class: "mort-form-text",
        #       data: {
        #         url: "/customers/lookup",
        #         div_id: "filter_customer_id",
        #         lookup_target: "input",
        #         action: "keydown->lookup#keyDown blur->filter#customerChange"
        #       },
        #       display_value: @resource.customer_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
        #   end
        #
        # when assoc.to_s.downcase =~ /punchclock/
        #   div(class: "mort-field", id: "filter_punch_clock_id") do
        #     row field(:punch_clock_id).lookup(class: "mort-form-text",
        #       data: {
        #         url: "/punch_clocks/lookup",
        #         div_id: "filter_punch_clock_id",
        #         lookup_target: "input",
        #         action: "keydown->lookup#keyDown blur->filter#customerChange"
        #       },
        #       display_value: @resource.punch_clock_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
        #   end
        #
        # when assoc.to_s.downcase =~ /product/
        #   div(class: "mort-field", id: "filter_product_id") do
        #     row field(:product_id).lookup(class: "mort-form-text",
        #       data: {
        #         url: "/products/lookup",
        #         div_id: "filter_product_id",
        #         lookup_target: "input",
        #         action: "keydown->lookup#keyDown blur->filter#customerChange"
        #       },
        #       display_value: @resource.product_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
        #   end
        #
        # when assoc.to_s.downcase =~ /location/
        #   div(class: "mort-field", id: "filter_location_id") do
        #     row field(:location_id).lookup(class: "mort-form-text",
        #       data: {
        #         url: "/locations/lookup",
        #         div_id: "filter_location_id",
        #         lookup_target: "input",
        #         action: "keydown->lookup#keyDown blur->filter#customerChange"
        #       },
        #       display_value: @resource.location_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
        #   end
        #
        # when assoc.to_s.downcase =~ /invoice/
        #   div(class: "mort-field", id: "filter_invoice_id") do
        #     row field(:invoice_id).lookup(class: "mort-form-text",
        #       data: {
        #         url: "/invoices/lookup",
        #         div_id: "filter_invoice_id",
        #         lookup_target: "input",
        #         action: "keydown->lookup#keyDown blur->filter#customerChange"
        #       },
        #       display_value: @resource.invoice_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
        #   end
        #
        # when assoc.to_s.downcase =~ /invoiceitem/
        #   div(class: "mort-field", id: "filter_invoice_item_id") do
        #     row field(:invoice_item_id).lookup(class: "mort-form-text",
        #       data: {
        #         url: "/invoice_items/lookup",
        #         div_id: "filter_invoice_item_id",
        #         lookup_target: "input",
        #         action: "keydown->lookup#keyDown blur->filter#customerChange"
        #       },
        #       display_value: @resource.invoice_item_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
        #   end
        #
        # when assoc.to_s.downcase =~ /project/
        #   div(class: "mort-field", id: "filter_project_id") do
        #     row field(:project_id).lookup(class: "mort-form-text",
        #       data: {
        #         url: "/projects/lookup",
        #         div_id: "filter_project_id",
        #         lookup_target: "input",
        #         action: "keydown->lookup#keyDown blur->filter#customerChange"
        #       },
        #       display_value: @resource.project_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
        #   end
        #
        # end
      end
    end
  end

  def list_association_fields(assoc)
    li do
      comment { %(Current: "bg-gray-50", Default: "hover:bg-gray-50") }
      div do
        button(
          data: { action: "filter#toggleAssociationFieldList", list: "#{assoc.to_s.underscore}_fields" },
          type: "button",
          class:
            "flex w-full items-center gap-x-3 rounded-md p-2 text-left text-sm leading-6 text-gray-700 hover:bg-gray-50",
          aria_controls: "sub-menu-1",
          aria_expanded: "false"
        ) do
          comment do
            %(Expanded: "rotate-90 text-gray-500", Collapsed: "text-gray-400")
          end
          svg(
            class: "h-5 w-5 shrink-0 text-gray-400",
            viewbox: "0 0 20 20",
            fill: "currentColor",
            aria_hidden: "true",
            data_slot: "icon"
          ) do |s|
            s.path(
              fill_rule: "evenodd",
              d:
                "M8.22 5.22a.75.75 0 0 1 1.06 0l4.25 4.25a.75.75 0 0 1 0 1.06l-4.25 4.25a.75.75 0 0 1-1.06-1.06L11.94 10 8.22 6.28a.75.75 0 0 1 0-1.06Z",
              clip_rule: "evenodd"
            )
          end
          plain I18n.t("activerecord.models.#{assoc.to_s.underscore}.one")
        end
        comment { "Expandable link section, show/hide based on state." }
        ul(class: "hidden mt-1 px-2", id: "#{assoc.to_s.underscore}_fields") do
          list_fields(assoc)
        end
      end
    end
  end

  # selected = one of <, >, =, !=, between, not_between, matches, does_not_match, more
  #
  def list_fields(model)
    return unless model
    (model.filterable_fields).each do |col|
      render FieldComponent.new model: model, field: col, filter: resource
    end
  end

  def user_scope
    div(class: "mt-3 space-y-4") do
      #
      user_scope = resource.filter["scope"] && resource.filter["scope"]["user"] ?
        resource.filter["scope"]["user"] :
        ""
      div(class: "flex items-center") do
        input(
          id: "filter_scope_user_mine",
          name: "filter[scope][user]",
          value: "mine",
          type: "radio",
          checked: user_scope == "mine", # ."checked",
          class: "h-4 w-4 border-gray-300 text-sky-200 focus:ring-sky-200"
        )
        label(
          for: "filter_scope_user_mine",
          class: "ml-3 block text-sm font-medium leading-6 text-gray-900"
        ) { I18n.t("filters.scope.user.mine") }
      end
      div(class: "flex items-center") do
        input(
          id: "filter_scope_user_team",
          name: "filter[scope][user]",
          value: "my_team",
          type: "radio",
          checked: user_scope == "my_team",
          class: "h-4 w-4 border-gray-300 text-sky-200 focus:ring-sky-200"
        )
        label(
          for: "filter_scope_user_team",
          class: "ml-3 block text-sm font-medium leading-6 text-gray-900"
        ) { I18n.t("filters.scope.user.team") }
      end
      div(class: "flex items-center") do
        input(
          id: "filter_scope_user_all",
          name: "filter[scope][user]",
          value: "all",
          type: "radio",
          checked: user_scope == "all",
          class: "h-4 w-4 border-gray-300 text-sky-200 focus:ring-sky-200"
        )
        label(
          for: "filter_scope_user_all",
          class: "ml-3 block text-sm font-medium leading-6 text-gray-900"
        ) { I18n.t("filters.scope.user.all") }
      end
      named_scope = resource.filter["scope"] && resource.filter["scope"]["named_users_teams"] ?
        resource.filter["scope"]["named_users_teams"] :
        ""
      input(class: "mort-form-text",
        name: "filter[scope][named_users_teams]",
        value: named_scope,
        placeholder: I18n.t("filters.scope.user.named_users_teams"))
    end
  end

  def association_scope(model)
    lower = model.to_s.underscore
    div(class: "mort-field", id: "filter_#{lower}_id") do
      row field("#{lower}_id".to_sym).lookup(class: "mort-form-text",
        data: {
          url: "/#{model.table_name}/lookup",
          div_id: "filter_#{lower}_id",
          lookup_target: "input",
          value: resource.filter["#{lower}_id"],
          action: "keydown->lookup#keyDown"
        },
        display_value: resource.filter["#{lower}_name"]), "mort-field my-1"
    end
  end
end
