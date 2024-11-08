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
      div do
        div(class: "") do
          p(class: "text-xs text-gray-400") { I18n.t("time_material.type.warning") }
          div(class: "") do
            nav(class: "-mb-px flex space-x-8", aria_label: "Tabs") do
              time_tab
              material_tab
            end
          end
        end
        show_time_tab
        show_material_tab
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
      # form_actions

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
      class: "flex justify-center tab-header w-1/2 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-sky-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        svg(
          class:
            "-ml-0.5 mr-2 h-5 w-5 text-sky-500 group-hover:text-sky-500 pointer-events-none",
          viewbox: "0 0 20 20",
          fill: "currentColor",
          aria_hidden: "true",
          data_slot: "icon",
          data: { time_material_target: "timetab" }
        ) do |s|
          s.path(
            d:
              "M10 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM3.465 14.493a1.23 1.23 0 0 0 .41 1.412A9.957 9.957 0 0 0 10 18c2.31 0 4.438-.784 6.131-2.1.43-.333.604-.903.408-1.41a7.002 7.002 0 0 0-13.074.003Z"
          )
        end
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
      class: "flex justify-center tab-header w-1/2 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-sky-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        svg(
          class:
            "-ml-0.5 mr-2 h-5 w-5 text-gray-400 group-hover:text-gray-500 pointer-events-none",
          viewbox: "0 0 20 20",
          fill: "currentColor",
          aria_hidden: "true",
          data_slot: "icon",
          data: { time_material_target: "materialtab" }
        ) do |s|
          s.path(
            fill_rule: "evenodd",
            d:
              "M4 16.5v-13h-.25a.75.75 0 0 1 0-1.5h12.5a.75.75 0 0 1 0 1.5H16v13h.25a.75.75 0 0 1 0 1.5h-3.5a.75.75 0 0 1-.75-.75v-2.5a.75.75 0 0 0-.75-.75h-2.5a.75.75 0 0 0-.75.75v2.5a.75.75 0 0 1-.75.75h-3.5a.75.75 0 0 1 0-1.5H4Zm3-11a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1ZM7.5 9a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1ZM11 5.5a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1Zm.5 3.5a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1Z",
            clip_rule: "evenodd"
          )
        end
        span(class: "pointer-events-none") { I18n.t("time_material.type.material") }
    end
  end

  def show_time_tab
    div(id: "time", data: { tabs_target: "tabPanel" }, class: "time-material-type time tab ") do
      div(class: "space-y-2 ") do
        div(class: "border-b border-gray-900/10 pb-2") do
          div(class: "mt-2 grid grid-cols-4 gap-x-4 gap-y-4 ") do
            #
            about_field
            #
            div(class: "col-span-1") do
              row field(:time).input(class: "mort-form-text"), ""
              # label(for: "time", class: "block text-sm font-medium leading-6 text-gray-900") { I18n.t("time_material.time.lbl") }
              # div(class: "mt-2") do
              #   div(
              #     class:
              #       "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
              #   ) do
              #     input(
              #       type: "tel",  # hack to allow iOS to show numeric keyboard
              #       name: "time_material[time]",
              #       id: "time_material_time",
              #       pattern: "[0-9,.]*",
              #       value: @resource.time,
              #       class:
              #         "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
              #       placeholder: "0,25"
              #     )
              #   end
              # end
            end
            #
            rate_field I18n.t("time_material.rate.hourly")
            #
            div(class: "col-span-1") do
              row field(:overtime).boolean(class: "flex h-8 items-center"), ""
            end
          end
        end
      end
    end
  end

  def show_material_tab
    div(id: "material", data: { tabs_target: "tabPanel" }, class: "time-material-type material tab hidden") do
      div(class: "space-y-2") do
        div(class: "border-b border-gray-900/10 pb-2") do
          div(class: "mt-2 grid grid-cols-4 gap-x-4 gap-y-4") do
            div(class: "col-span-4") do
              row field(:product_id).lookup(class: "mort-form-text",
                data: {
                  url: "/products/lookup",
                  div_id: "time_material_product_id",
                  lookup_target: "input",
                  action: "keydown->lookup#keyDown blur->time-material#productChange"
                },
                role: "time_material",
                display_value: @resource.product_name), "" # Customer.all.select(:id, :name).take(9)
            end
            div(class: "col-span-4") do
              row field(:comment).textarea(class: "mort-form-text"), ""
            end
            div(class: "col-span-4 grid gap-x-2 grid-cols-9") do
              div(class: "col-span-2") do
                row field(:quantity).input(class: "mort-form-text"), ""
              end
              div(class: "col-span-2") do
                row field(:unit).select(@resource.units, class: "mort-form-text text-sm"), ""
              end
              div(class: "col-span-3") do
                row field(:unit_price).input(class: "mort-form-text"), ""
              end
              div(class: "col-span-2") do
                row field(:discount).input(class: "mort-form-text", placeholder: I18n.t("time_material.discount.placeholder")), ""
              end
            end
          end
        end
      end
    end
  end

  def about_field
    div(class: "col-span-full") do
      row field(:about).textarea(class: "mort-form-text").focus, ""
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
      display_value: @resource.customer_name), "" # Customer.all.select(:id, :name).take(9)
    # div(class: "mt-4 col-span-4") do
    #   label(for: "time_material_customer_id", class: "block text-sm font-medium leading-6 text-gray-900") { I18n.t("time_material.customer.lbl") }
    #   div(class: "mt-2") do
    #     div(class: "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md") do
    #       input(
    #         name: "time_material[project_name]",
    #         id: "time_material_project_name",
    #         autocomplete: "project",
    #         value: @resource.project_name,
    #         class:
    #           "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
    #         placeholder: I18n.t("time_material.project.placeholder")
    #       )
    #     end
    #   end
    # end
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
      display_value: @resource.project_name), "" # Customer.all.select(:id, :name).take(9)
  end

  def rate_field(lbl, css = "col-span-2", fld_name = "rate")
    div(class: css) do
      row field(fld_name.to_sym).input(class: "mort-form-text"), ""
      # label(for: "time_material_#{fld_name}", class: "block text-sm font-medium leading-6 text-gray-900") { lbl }
      # div(class: "mt-2") do
      #   div(
      #     class:
      #       "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
      #   ) do
      #     input(
      #       name: "time_material[#{fld_name}]",
      #       id: "time_material_#{fld_name}",
      #       value: @resource.send(fld_name),
      #       class:
      #         "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
      #       placeholder: "90,25"
      #     )
      #   end
      # end
    end
  end

  def invoicing
    div(class: "pb-12") do
      div(class: "mt-2 space-y-1") do
        row field(:state).select(TimeMaterial.time_material_states, class: "my-auto mort-form-select") # , "flex justify-end flex-row-reverse items-center"
        fieldset do
          legend(class: "text-sm font-semibold leading-6 text-gray-900") { I18n.t("time_material.invoicing.lead") }
          div(class: "mt-6 space-y-1") do
            row field(:is_invoice).boolean(data: { time_material_target: "invoice" }, class: "my-auto mort-form-bool"), "flex justify-end flex-row-reverse items-center"
            row field(:is_separate).boolean(class: "my-auto mort-form-bool"), "flex justify-end flex-row-reverse items-center"
            # div(class: "relative flex gap-x-3") do
            #   div(class: "flex h-6 items-center") do
            #     input(
            #       id: "time_material_is_invoice",
            #       name: "time_material[is_invoice]",
            #       data: { time_material_target: "invoice" },
            #       type: "checkbox",
            #       checked: @resource.is_invoice?,
            #       class: "h-4 w-4 rounded border-gray-300 text-sky-600 focus:ring-sky-600"
            #     )
            #   end
            #   div(class: "text-sm leading-6") do
            #     label(for: "time_material_is_invoice", class: "font-medium text-gray-900") { I18n.t("time_material.invoicing.invoice.lbl") }
            #     p(class: "text-gray-500") { I18n.t("time_material.invoicing.invoice.help") }
            #   end
            # end

            # row field(:is_free).boolean(class: "my-auto mort-form-bool"), "flex justify-end flex-row-reverse items-center"

            # div(class: "relative flex gap-x-3") do
            #   div(class: "flex h-6 items-center") do
            #     input(
            #       id: "time_material_is_free",
            #       name: "time_material[is_free]",
            #       type: "checkbox",
            #       checked: @resource.is_free?,
            #       class: "h-4 w-4 rounded border-gray-300 text-sky-600 focus:ring-sky-600"
            #     )
            #   end
            #   div(class: "text-sm leading-6") do
            #     label(for: "time_material_is_free", class: "font-medium text-gray-900") { I18n.t("time_material.invoicing.free.lbl") }
            #     p(class: "text-gray-500") { I18n.t("time_material.invoicing.free.help") }
            #   end
            # end
            # div(class: "relative flex gap-x-3") do
            #   div(class: "flex h-6 items-center") do
            #     input(
            #       id: "time_material_is_offer",
            #       name: "time_material[is_offer]",
            #       type: "checkbox",
            #       disabled: "disabled",
            #       class: "h-4 w-4 rounded border-gray-300 text-sky-600 focus:ring-sky-600"
            #     )
            #   end
            #   div(class: "text-sm leading-6") do
            #     label(for: "time_material_is_offer", class: "font-medium text-gray-900") { I18n.t("time_material.invoicing.offer.lbl") }
            #     p(class: "text-gray-500") { I18n.t("time_material.invoicing.offer.help") }
            #   end
            # end
          end
        end
        # fieldset do
        #   # legend(class: "text-sm font-semibold leading-6 text-gray-900") { I18n.t("time_material.invoicing.batch.lbl") }
        #   div(class: "mt-0 space-y-6") do
        #     div(class: "relative flex gap-x-3") do
        #       row field(:is_separate).boolean(class: "my-auto mort-form-bool"), "flex justify-end flex-row-reverse items-center"

        #       # div(class: "flex h-6 items-center") do
        #       #   input(
        #       #     id: "time_material_is_separate",
        #       #     name: "time_material[is_separate]",
        #       #     type: "checkbox",
        #       #     checked: @resource.is_separate?,
        #       #     class: "h-4 w-4 rounded border-gray-300 text-sky-600 focus:ring-sky-600"
        #       #   )
        #       # end
        #       # div(class: "text-sm leading-6") do
        #       #   label(for: "time_material_is_separate", class: "font-medium text-gray-900") { I18n.t("time_material.invoicing.separate.lbl") }
        #       #   p(class: "text-gray-500") { I18n.t("time_material.invoicing.separate.help") }
        #       # end
        #     end
        #   end
        # end
      end
    end
  end

  # def error_messages
  #   if @resource.errors.any?
  #     div(id: "error_explanation", class: "mt-4 p-4 sm: p-1") do
  #       h2(class: "mort-err-resume") { I18n.t(:form_errors_prohibited, errors: @resource.errors.count) }
  #       ul do
  #         @resource.errors.each do |error|
  #           li { error.full_message }
  #         end
  #       end
  #     end
  #   end
  # end

  def show_possible_issues
    ul() do
      li() { "customer missing" } if @resource.is_invoice? and
        @resource.customer_id.blank?
      li() { "product missing" } if @resource.product_id.nil? and
        @resource.is_invoice? and
        @resource.product_name.blank? and
        @resource.quantity != 0
      li() { "time not correct" } if (@resource.time =~ /^\d*[,.]?\d*$/).nil?
      li() { "rate not correct" } if (@resource.rate =~ /^\d*[,.]?\d*$/).nil?
      li() { "quantity not correct" } if !@resource.quantity.blank? and
        (@resource.quantity =~ /^\d*[,.]?\d*$/).nil?
      li() { "time and quantity both set" } if !@resource.quantity.blank? and
        !@resource.time.blank?
      li() { "unit_price not correct" } if !@resource.unit_price.blank? and
        (@resource.unit_price =~ /^\d*[,.]?\d*$/).nil?
      li() { "discount not correct" } if !@resource.discount.blank? and
        (@resource.discount =~ /^\d*[,.]?\d*[ ]*%?$/).nil?
    end
  end
  # def date_field
  #   div(class: "mt-2 sm:col-span-4") do
  #     label(for: "date", class: "block text-sm font-medium leading-6 text-gray-900") { I18n.t("time_material.date.lbl") }
  #     div(class: "mt-2") do
  #       div(
  #         class:
  #           "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
  #       ) do
  #         input(
  #           type: "date",
  #           name: "time_material[date]",
  #           id: "time_material_date",
  #           value: @resource.date,
  #           class:
  #             "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6"
  #         )
  #       end
  #     end
  #   end
  # end

  def form_actions
    div(class: "my-6 flex items-center justify-end gap-x-6") do
      render CancelSaveForm.new cancel_url: @resources_url, title: I18n.t("%s.form.new" % @resource.class.table_name)
      # link_to(time_materials_url, class: "mort-btn-cancel") { "Fortryd" }
      # button(type: "submit", class: "mort-btn-save") { "Gem" }
    end
  end
end
