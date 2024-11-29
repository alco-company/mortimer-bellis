class TimeMaterials::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "time-material tabs", tabs_index: "0" }) do
      if model.cannot_be_pushed?
        div(class: "text-sm mt-2 bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded relative") do
          show_possible_issues
        end
      end
      # date_field
      div(class: "mt-2 sm:col-span-4") do
        row field(:date).date(class: "mort-form-text")
      end
      # user
      if Current.user.can?(:delegate_time_materials)
        div(class: "mt-2 sm:col-span-4") do
          row field(:user_id).select(User.all.order(name: :asc).select(:id, :name), class: "mort-form-select")
        end
      end
      #
      div(class: "border border-gray-900/10 rounded-md bg-slate-50 p-2") do
        div(class: "") do
          p(class: "text-xs text-gray-400") { I18n.t("time_material.type.warning") }
          div(class: "") do
            nav(class: "-mb-px flex space-x-8", aria_label: "Tabs") do
              time_tab
              material_tab
              mileage_tab
            end
          end
        end
        show_time_tab
        show_material_tab
        show_mileage_tab
      end
      #
      #
      customer_field
      #
      project_field
      #

      #
      invoicing

      # url = @resource.id.nil? ? time_materials_url : time_material_url(@resource)
      # render TimeMaterialForm.new time_material: @resource, url: url
      if @resource.pushed_to_erp?
        view_only field(:pushed_erp_timestamp).input(class: "mort-form-text")
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
      class: "flex justify-center tab-header w-1/2 border-b-2 border-transparent p-2 pt-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-sky-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        render Icons::Person.new(cls: "-ml-0.5 mr-2 h-5 w-5 text-sky-500 group-hover:text-sky-500 pointer-events-none", data: { time_material_target: "timetab" })
        span(class: "pointer-events-none") { I18n.t("time_material.type.time") }
    end
  end

  def material_tab
    # comment do
    #   %(Current: "border-sky-500 text-sky-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
    # end
    button(
      type: "button",
      data: { tabs_target: "tab", action: "tabs#change" },
      value: 1,
      class: "flex justify-center tab-header w-1/2 border-b-2 border-transparent p-2 pt-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-sky-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        render Icons::Building.new(cls: "-ml-0.5 mr-2 h-5 w-5 text-gray-400 group-hover:text-gray-500 pointer-events-none", data: { time_material_target: "materialtab" })
        span(class: "pointer-events-none") { I18n.t("time_material.type.material") }
    end
  end

  def mileage_tab
    # comment do
    #   %(Current: "border-sky-500 text-sky-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
    # end
    button(
      type: "button",
      data: { tabs_target: "tab", action: "tabs#change" },
      value: 2,
      class: "flex justify-center tab-header w-1/2 border-b-2 border-transparent p-2 pt-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-sky-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        render Icons::Transportation.new(cls: "-ml-0.5 mr-2 h-5 w-5 text-gray-400 group-hover:text-gray-500 pointer-events-none", data: { time_material_target: "mileagetab" })
        span(class: "pointer-events-none") { I18n.t("time_material.type.mileage") }
    end
  end

  def show_time_tab
    div(id: "time", data: { tabs_target: "tabPanel" }, class: "time-material-type time tab ") do
      div(class: "space-y-2 ") do
        div(class: "pb-2") do
          div(class: "mt-2 grid grid-cols-4 gap-x-4 gap-y-1 ") do
            #
            about_field
            #
            div(class: "col-span-1") do
              row field(:time).input(class: "mort-form-text"), "mort-field my-1"
            end
            #
            rate_field I18n.t("time_material.rate.hourly")
            #
            div(class: "col-span-2") do
              row field(:over_time).select(TimeMaterial.overtimes, class: "mort-form-select"), "mort-field my-1"
            end
          end
        end
      end
    end
  end

  def show_material_tab
    div(id: "material", data: { tabs_target: "tabPanel" }, class: "time-material-type material tab hidden") do
      div(class: "space-y-2") do
        div(class: " pb-2") do
          div(class: "mt-2 grid grid-cols-4 gap-x-4 gap-y-1") do
            div(class: "col-span-4") do
              row field(:product_id).lookup(class: "mort-form-text",
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
                row field(:quantity).input(class: "mort-form-text"), "mort-field my-1"
              end
              div(class: "col-span-2") do
                row field(:unit).select(@resource.units, class: "mort-form-text text-sm"), "mort-field my-1"
              end
            end
            div(class: "col-span-4 grid gap-x-2 grid-cols-5") do
              div(class: "col-span-3") do
                row field(:unit_price).input(class: "mort-form-text"), "mort-field my-1"
              end
              div(class: "col-span-2") do
                row field(:discount).input(class: "mort-form-text", placeholder: I18n.t("time_material.discount.placeholder")), "mort-field my-1"
              end
            end
          end
        end
      end
    end
  end

  def show_mileage_tab
    div(id: "material", data: { tabs_target: "tabPanel" }, class: "time-material-type material tab hidden") do
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
                row field(:kilometers).input(class: "mort-form-text", data: { time_material_target: "mileage" }), "mort-field my-1"
              end
              div(class: "col-span-6") do
                row field(:trip_purpose).select(TimeMaterial.trip_purposes, class: "mort-form-select"), "mort-field my-1"
              end
            end
            div(class: "col-span-4 grid gap-x-2 grid-cols-4") do
              div(class: "col-span-4") do
                row field(:odo_from_time).datetime(class: "mort-form-text"), "mort-field my-1"
              end
              div(class: "col-span-4") do
                row field(:odo_to_time).datetime(class: "mort-form-text"), "mort-field my-1"
              end
            end
          end
        end
      end
    end
  end

  def about_field
    div(class: "col-span-full") do
      row field(:about).textarea(class: "mort-form-text").focus, "mort-field my-0"
    end
  end

  def customer_field
    row field(:customer_id).lookup(class: "mort-form-text",
      data: {
        url: "/customers/lookup",
        div_id: "time_material_customer_id",
        lookup_target: "input",
        action: "keydown->lookup#keyDown blur->time-material#customerChange"
      },
      display_value: @resource.customer_name), "mort-field" # Customer.all.select(:id, :name).take(9)
  end

  def project_field
    row field(:project_id).lookup(class: "mort-form-text",
      data: {
        url: "/projects/lookup",
        div_id: "time_material_project_id",
        lookup_target: "input",
        lookup_association: "customer_id",
        lookup_association_div_id: "time_material_customer_id",
        action: "keydown->lookup#keyDown blur->time-material#projectChange"
      },
      display_value: @resource.project_name), "mort-field" # Customer.all.select(:id, :name).take(9)
  end

  def rate_field(lbl, css = "col-span-1", fld_name = "rate")
    div(class: css) do
      row field(fld_name.to_sym).input(class: "mort-form-text"), "mort-field my-1"
    end
  end

  def invoicing
    div(class: "pb-12") do
      div(class: "mt-2 space-y-1") do
        row field(:state).select(TimeMaterial.time_material_states, class: "my-auto mort-form-select"), "mort-field" # , "flex justify-end flex-row-reverse items-center"
        fieldset do
          legend(class: "text-sm font-semibold leading-6 text-gray-900") { I18n.t("time_material.invoicing.lead") }
          div(class: "mt-6 space-y-1") do
            row field(:is_invoice).boolean(data: { time_material_target: "invoice" }, class: "my-auto mort-form-bool"), "mort-field flex justify-end flex-row-reverse items-center"
            row field(:is_separate).boolean(class: "my-auto mort-form-bool"), "mort-field flex justify-end flex-row-reverse items-center"
          end
        end
      end
    end
  end

  def show_possible_issues
    ul() do
      li() { I18n.t("invoice_item.issues.customer_missing") }                   if @resource.is_invoice? and @resource.customer_id.blank?
      li() { I18n.t("invoice_item.issues.mileage_wrong") }                      if @resource.is_invoice? and !@resource.kilometers.blank? and is_mileage_wrong?
      li() { I18n.t("invoice_item.issues.product_missing") }                    if @resource.product_id.nil? and is_product_missing?
      li() { I18n.t("invoice_item.issues.time_not_correct") }                   if (@resource.time =~ /^\d*[,.]?\d*$/).nil?
      li() { I18n.t("invoice_item.issues.rate_not_correct") }                   if (@resource.rate =~ /^\d*[,.]?\d*$/).nil?
      li() { I18n.t("invoice_item.issues.quantity_not_correct") }               if !@resource.quantity.blank? and (@resource.quantity =~ /^\d*[,.]?\d*$/).nil?
      li() { I18n.t("invoice_item.issues.time_and_quantity_both_set") }         if !@resource.quantity.blank? and !@resource.time.blank?
      li() { I18n.t("invoice_item.issues.unit_price_not_correct") }             if !@resource.unit_price.blank? and (@resource.unit_price =~ /^\d*[,.]?\d*$/).nil?
      li() { I18n.t("invoice_item.issues.discount_not_correct") }               if !@resource.discount.blank? and (@resource.discount =~ /^\d*[,.]?\d*[ ]*%?$/).nil?
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
end
