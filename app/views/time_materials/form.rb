class TimeMaterials::Form < ApplicationForm
  def view_template(&)
    div(class: "overflow-y-auto", data: {
      controller: "time-material tabs",
      time_material_target: "item",
      form: "true",
      time_material_products_value: TimeMaterial.overtimes_products || {},
      tabs_index: @resource.is_time? ? "0" : "1" }) do
      if model.cannot_be_pushed?
        show_possible_issues
      end
      # date_field
      # user
      if user.can?(:delegate_time_materials, resource: @resource)
        div(class: "my-1 grid grid-cols-4 gap-x-1 md:gap-x-4 gap-y-1 ") do
          div(class: "my-0 col-span-4 xs:col-span-2") do
            row field(:date).date(class: "mort-form-date"), "mort-field my-0"
          end
          div(class: "my-0 col-span-4 xs:col-span-2") do
            row field(:user_id).select(User.by_tenant.order(name: :asc).select(:id, :name, :hourly_rate), data: { action: "change->time-material#userChanged" }, class: "mort-form-select my-0"), "mort-field my-0"
          end
        end
      else
        div(class: "mt-1") do
          row field(:date).date(class: "mort-form-date")
        end
      end
      #
      div(class: "border border-gray-900/10 rounded-md bg-slate-50 p-2") do
        div(class: "") do
          # p(class: "text-xs text-gray-400") { I18n.t("time_material.type.warning") }
          div(class: "w-full") do
            nav(class: "-mb-px flex space-x-2 border-b border-gray-900/10", aria_label: "Tabs") do
              time_tab
              material_tab
              mileage_tab
            end
          end
        end
        show_time_tab
        show_material_tab
        show_mileage_tab if Current.get_user.can? :see_mileage_tab, resource: @resource
      end
      #
      #
      customer_field
      #
      project_field
      #

      #
      invoicing

      #
      show_comments

      # url = @resource.id.nil? ? time_materials_url : time_material_url(@resource)
      # render TimeMaterialForm.new time_material: @resource, url: url
      if @resource.pushed_to_erp?
        view_only field(:pushed_erp_timestamp).input()
      end
      if @resource.cannot_be_pushed?
        view_only field(:push_log).textarea(class: "mort-form-text")
      end
    end
  end

  def time_tab
    # comment do
    #   %(Current: "border-sky-500 text-sky-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
    # end
    button(
      type: "button",
      data: { tabs_target: "tab", action: "tabs#change" },
      value: 0,
      class: "flex items-center justify-center tab-header w-1/3 border-b-2 border-transparent p-2 pt-1 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700  #{'hidden' unless @resource.is_time?}",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-sky-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        render Icons::Person.new(css: "-ml-0.5 mr-2 h-5 w-5 text-gray-400 group-hover:text-gray-500 pointer-events-none", data: { time_material_target: "timetab" })
        span(class: "pointer-events-none") { I18n.t("time_material.type.time") }
    end
  end

  def material_tab
    # comment do
    #   %(Current: "border-sky-500 text-sky-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
    # end
    return unless Current.get_user.can? :see_material_tab, resource: @resource
    button(
      type: "button",
      data: { tabs_target: "tab", action: "tabs#change" },
      value: 1,
      class: "flex items-center justify-center tab-header w-1/3 border-b-2 border-transparent p-2 pt-1 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-sky-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        render Icons::Building.new(css: "-ml-0.5 mr-2 h-5 w-5 text-gray-400 group-hover:text-gray-500 pointer-events-none", data: { time_material_target: "materialtab" })
        span(class: "pointer-events-none") { I18n.t("time_material.type.material") }
    end
  end

  def mileage_tab
    # comment do
    #   %(Current: "border-sky-500 text-sky-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
    # end
    return unless Current.get_user.can? :see_mileage_tab, resource: @resource
    button(
      type: "button",
      data: { tabs_target: "tab", action: "tabs#change" },
      value: 2,
      class: "flex items-center justify-center tab-header w-1/3 border-b-2 border-transparent p-2 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-sky-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        render Icons::Transportation.new(css: "-ml-0.5 mr-2 h-5 w-5 text-gray-400 group-hover:text-gray-500 pointer-events-none", data: { time_material_target: "mileagetab" })
        span(class: "pointer-events-none") { I18n.t("time_material.type.mileage") }
    end
  end

  #
  # about
  # hour_time
  # minute_time
  # rate
  # over_time
  #
  def show_time_tab
    div(id: "time", data: { tabs_target: "tabPanel" }, class: "time-material-type time tab #{'hidden' unless @resource.is_time?}") do
      div(class: "space-y-2 ") do
        div(class: "pb-2") do
          div(class: "mt-2 grid grid-cols-11 gap-x-1 sm:gap-x-4 gap-y-1 ") do
            #
            about_field
            #
            div(class: "col-span-2") do
              row field(:hour_time).input(type: "tel"), "mort-field my-1"
            end
            div(class: "col-span-2") do
              row field(:minute_time).input(type: "tel"), "mort-field my-1"
            end
            #
            rate_field(I18n.t("time_material.rate.hourly")) if Current.get_user.can?(:edit_hourly_rate, resource: @resource)
            #
            div(class: "col-span-4") do
              div(class: "hidden", id: "time_values", data: {})
              row field(:over_time).select(TimeMaterial.overtimes, data: { action: "change->time-material#updateOverTime" }, class: "mort-form-select"), "mort-field my-1"
            end if Current.get_user.can?(:edit_overtime, resource: @resource)
          end
        end
      end
    end
  end

  #
  # product_id
  # comment
  # quantity
  # unit
  # unit_price
  # discount
  #
  def show_material_tab
    return unless Current.get_user.can? :see_material_tab, resource: @resource
    div(id: "material", data: { tabs_target: "tabPanel" }, class: "time-material-type material tab #{'hidden' if @resource.is_time?}") do
      div(class: "space-y-2") do
        div(class: " pb-2") do
          div(class: "mt-2 grid grid-cols-4 gap-x-4 gap-y-1") do
            div(class: "col-span-4") do
              row field(:product_id).lookup(class: "mort-form-text #{ field_id_error(resource.product_name, resource.product_id, user.cannot?(:add_products)) }",
                data: {
                  url: "/products/lookup",
                  div_id: "time_material_product_id",
                  lookup_target: "input",
                  action: "keydown->lookup#keyDown blur->time-material#productChange"
                },
                role: "time_material",
                display_value: @resource.product_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
            end
            div(class: "col-span-4") do
              row field(:comment).textarea(class: "mort-form-text"), "mort-field my-1"
            end
            div(class: "col-span-4 grid gap-x-2 grid-cols-4") do
              div(class: "col-span-2") do
                row field(:quantity).input(), "mort-field my-1  #{ field_relation_error(resource.product_id, resource.quantity) }"
              end
              div(class: "col-span-2") do
                row field(:unit).select(@resource.units, class: "mort-form-select"), "mort-field my-1"
              end
            end
            div(class: "col-span-4 grid gap-x-2 grid-cols-5") do
              div(class: "col-span-3") do
                row field(:unit_price).input(), "mort-field my-1  #{ field_relation_error(resource.product_id, resource.unit_price) }"
              end
              div(class: "col-span-2") do
                row field(:discount).input(placeholder: I18n.t("time_material.discount.placeholder")), "mort-field my-1"
              end
            end
          end
        end
      end
    end
  end

  def show_mileage_tab
    return unless Current.get_user.can? :see_mileage_tab, resource: @resource
    div(id: "mileage", data: { tabs_target: "tabPanel" }, class: "time-material-type material tab hidden") do
      div(class: "space-y-2") do
        div(class: "pb-2") do
          div(class: "mt-2 grid grid-cols-4 gap-x-4 gap-y-1") do
            label(class: "col-span-4 block text-sm font-medium text-gray-700") { I18n.t("time_material.mileage.lead") }
            h3(class: "col-span-4 text-sm font-thin leading-6 text-gray-400") { unsafe_raw I18n.t("time_material.mileage.accounting_info") }
            div(class: "col-span-4 grid gap-x-2 grid-cols-4") do
              div(class: "col-span-2") do
                row field(:odo_from).input(type: "text", class: "mort-form-text", data: { time_material_target: "odofrom" }), " mort-field my-1"
              end
              div(class: "col-span-2") do
                row field(:odo_to).input(type: "text", class: "mort-form-text", data: {  time_material_target: "odoto", action: "blur->time-material#setMileage" }), "mort-field my-1"
              end
            end
            div(class: "col-span-4 grid gap-x-2 grid-cols-10") do
              div(class: "col-span-4") do
                row field(:kilometers).input(data: { time_material_target: "mileage" }), "mort-field my-1"
              end
              div(class: "col-span-6") do
                row field(:trip_purpose).select(TimeMaterial.trip_purposes, class: "mort-form-select"), "mort-field my-1"
              end
            end
            div(class: "col-span-4 grid gap-x-2 grid-cols-4") do
              div(class: "col-span-4") do
                row field(:odo_from_time).datetime(class: "mort-form-datetime"), "mort-field my-1"
              end
              div(class: "col-span-4") do
                row field(:odo_to_time).datetime(class: "mort-form-datetime"), "mort-field my-1"
              end
            end
          end
        end
      end
    end
  end

  def about_field
    div(class: "col-span-full") do
      div(class: "mort-field my-0") do
        div(class: "flex justify-between", data: {}) do
          label(for: "time_material_about", class: "block text-sm font-medium leading-6 text-gray-900") { I18n.t("time_material.about.lbl") }
          if resource.active? or resource.paused?
            color = resource.paused? ? "text-gray-500" : "text-lime-500"
            seconds = resource.minutes_reloaded_at.nil? ? (Time.current.to_i - resource.started_at.to_i) : (Time.current.to_i - resource.minutes_reloaded_at.to_i)
            counter = (resource.registered_minutes || 0) * 60 + seconds
            _days, hours, minutes, seconds = resource.calc_hrs_minutes counter
            timestring = "%02d:%02d:%02d" % [ hours, minutes, seconds ]
            div(class: "float-right") do
              span(class: "text-xs font-light #{color} grow mr-2 time_counter", data: { counter: counter, state: resource.state, time_material_target: "counter" }) { timestring }
            end
          end
        end
        textarea(id: "time_material_about", name: "time_material[about]", class: "mort-form-text", autofocus: true) do
          plain resource.about
        end
      end
    end
    div(class: "hidden col-span-full") do
      div(class: "flex justify-between") do
        p(class: "mt-3 text-sm leading-6 text-gray-600") { Time.current.to_datetime }
        p(class: "mt-3 text-sm leading-6 text-gray-600") { resource.started_at&.to_datetime }
        p(class: "mt-3 text-sm leading-6 text-gray-600") { resource.paused_at&.to_datetime }
        p(class: "mt-3 text-sm leading-6 text-gray-600") { ("%s %s" % resource.time_spent.divmod(60)) rescue "" }
      end
    end

    # row field(:about).textarea(class: "mort-form-text").focus, "mort-field my-0"
  end

  def customer_field
    return unless Current.get_user.can? :use_customers, resource: @resource
    row field(:customer_id).lookup(class: "mort-form-text #{field_id_error(resource.customer_name, resource.customer_id, resource.is_invoice?)}",
      data: {
        url: "/customers/lookup",
        div_id: "time_material_customer_id",
        lookup_target: "input",
        action: "keydown->lookup#keyDown blur->time-material#customerChange"
      },
      display_value: @resource.customer_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
  end

  def project_field
    return unless Current.get_user.can?(:use_projects, resource: @resource) &&
      Current.get_tenant.license_valid? &&
      %w[trial ambassador pro].include?(Current.get_tenant.license)

    row field(:project_id).lookup(class: "mort-form-text #{field_id_error(resource.project_name, resource.project_id)}",
      data: {
        url: "/projects/lookup",
        div_id: "time_material_project_id",
        lookup_target: "input",
        lookup_association: "customer_id",
        lookup_association_div_id: "time_material_customer_id",
        action: "keydown->lookup#keyDown blur->time-material#projectChange"
      },
      display_value: @resource.project_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
  end

  def rate_field(lbl, css = "col-span-3", fld_name = "rate")
    div(class: css) do
      row field(fld_name.to_sym).input(data: { action: "change->time-material##{fld_name}Change" }), "mort-field my-1"
    end
  end

  def invoicing
    return unless Current.get_user.can? :do_invoicing, resource: @resource
    div(class: "pb-4 rounded-md border border-gray-300 bg-gray-50 p-2") do
      div(class: "mt-1 space-y-1") do
        row field(:state).select(TimeMaterial.time_material_states, class: "my-auto mort-form-select"), "mort-field" # , "flex justify-end flex-row-reverse items-center"
        fieldset do
          legend(class: "text-sm font-semibold leading-6 text-gray-900") { I18n.t("time_material.invoicing.lead") }
          div(class: "mt-1 space-y-1") do
            row field(:is_invoice).boolean(data: { time_material_target: "invoice" }, class: "my-auto mort-form-bool "), "mort-field #{field_bool_error(resource.is_invoice, resource.customer_id)} my-1 flex justify-end flex-row-reverse items-center"
            row field(:is_separate).boolean(class: "my-auto mort-form-bool"), "mort-field my-1 flex justify-end flex-row-reverse items-center"
          end
        end
      end
    end
  end

  def show_possible_issues
    entry = InvoiceItemValidator.new(@resource, @resource.user)
    if entry.valid?
      div(class: "text-sm mt-2 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-sm relative") do
        p() { I18n.t("invoice_item.issues.no_issues") }
      end
    else
      div(class: "text-sm mt-2 bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded-sm relative") do
        ul(class: "grid gap-y-2") do
          entry.errors.each do |error|
            li() { unsafe_raw "<strong>%s</strong> - %s" % [ I18n.t("activerecord.attributes.time_material.#{error.attribute}"), error.type ] }
          end
        end
      end
    end
  end

  def field_id_error(value, dependant, allowed = true)
    if !value.blank? and dependant.blank? and allowed
      "border-1 border-red-500"
    end
  end

  def field_relation_error(other_value, value)
    if !other_value.blank? and value.blank?
      "border-1 border-red-500"
    end
  end

  def field_bool_error(value, dependant, allowed = true)
    if value and dependant.blank? and allowed
      "border-1 border-red-500"
    end
  end

  def is_product_missing?
    @resource.is_invoice? and @resource.product_name.blank? and @resource.quantity != 0
  end

  def is_mileage_wrong?
    (@resource.kilometers != @resource.odo_to - @resource.odo_from) or
    (@resource.kilometers < 0) or
    (@resource.odo_to < @resource.odo_from) or
    (@resource.odo_from_time > @resource.odo_to_time) or
    (@resource.odo_from_time.blank?) or
    (@resource.odo_to_time.blank?)
  end

  def calc_time_spent(time_spent)
    if time_spent.nil?
      I18n.t("time_material.no_time_spent")
    else
      days, hours, minutes, _seconds = @resource.calc_hrs_minutes(time_spent)
      I18n.t("time_material.time_spent", time_spent: "#{days}d #{hours}h #{minutes}m")
    end
  end

  def show_time_spent(time_spent)
    if time_spent.nil?
      "00:00"
    else
      days, hours, minutes, _seconds = @resource.calc_hrs_minutes(time_spent)
      "#{days}d #{hours}h #{minutes}m"
    end
  end

  def show_comments
    render TagComponent.new(resource: resource,
    field: :tag_list,
    show_label: true,
    value_class: "mr-5",
    value: resource.tags,
    editable: true) if Current.get_user.can?(:add_tags_on_time_material, resource: @resource)

    return unless Current.get_user.can? :add_comments_on_time_material, resource: @resource
    div(class: "col-span-full") do
      div(class: "mort-field my-1") do
        div(class: "flex justify-between", data: {}) do
          label(for: "time_material_task_comment") do
            span { I18n.t("activerecord.attributes.time_material.task_comment") }
          end
        end
        textarea(id: "time_material_task_comment", name: "time_material[task_comment]", class: "mort-form-text") do
          plain resource.task_comment
        end
      end
      div(class: "mort-field my-0") do
        div(class: "flex justify-between", data: {}) do
          label(for: "time_material_location_comment") do
            span { I18n.t("activerecord.attributes.time_material.location_comment") }
          end
        end
        textarea(id: "time_material_location_comment", name: "time_material[location_comment]", class: "mort-form-text") do
          plain resource.location_comment
        end
      end
    end
  end
end
