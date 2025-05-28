class TimeMaterialForm < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Pluralize

  def initialize(time_material:, url:)
    @time_material = time_material
    @url = url
    @method = time_material.new_record? ? "post" : "patch"
  end

  #  TimeMaterial tenant:references date time about customer customer_id project project_id product product_id quantity rate discount is_invoice:boolean is_free:boolean is_offer:boolean is_separate:boolean

  def view_template
    # div(class: "relative flex min-h-screen flex-col overflow-hidden mx-auto w-full lg:mx-0 lg:float-right py-6 sm:py-12") do
    #   div(class: "relative bg-white px-6 pb-8 pt-10 ring-1 ring-gray-900/5 sm:rounded-lg sm:px-2", data: { controller: "tabs", tabs_index: "0" }) do
    div(class: "mx-auto max-w-full", data: { controller: "tabs", tabs_index: "0" }) do
      form(action: @url, method: @method, data: { form_target: "form" },  class: "mort-form") do
        input(type: "hidden", name: "time_material[user_id]", value: @time_material.user_id)
        #
        date_field
        #
        div do
          div(class: "") do
            # error_messages


            div(class: "border-b border-gray-200") do
              nav(class: "-mb-px flex space-x-8", aria_label: "Tabs") do
                time_tab
                material_tab
              end
            end
          end
        end
        #
        show_time_tab
        show_material_tab
        #
        customer_field
        #
        project_field
        #

        #
        invoicing
        #
        form_actions
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
          data_slot: "icon"
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
          data_slot: "icon"
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
        div(class: "border-b border-gray-900/10") do
          div(class: "mt-2 grid grid-cols-4 gap-x-4 gap-y-4 ") do
            #
            about_field
            #
            div(class: "col-span-2") do
              label(for: "time", class: "block text-sm font-medium leading-6 text-gray-900") { I18n.t("time_material.time.lbl") }
              div(class: "mt-2") do
                div(
                  class:
                    "flex rounded-md shadow-xs ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
                ) do
                  input(
                    name: "time_material[time]",
                    id: "time_material_time",
                    value: @time_material.time,
                    class:
                      "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                    placeholder: "1,25 or 1.15 or 10:00-11:15"
                  )
                end
              end
            end
            #
            rate_field I18n.t("time_material.rate.hourly")
            #
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
              whitespace
              label(
                for: "product_name",
                class: "block text-sm font-medium leading-6 text-gray-900"
              ) { I18n.t("time_material.product.lbl")  }
              div(class: "mt-2") do
                div(
                  class:
                    "flex rounded-md shadow-xs ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
                ) do
                  whitespace
                  input(
                    name: "time_material[product_name]",
                    id: "time_material_product_name",
                    value: @time_material.product_name,
                    class:
                      "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                    placeholder: I18n.t("time_material.product.placeholder")
                  )
                end
              end
            end
            div(class: "col-span-4") do
              whitespace
              label(
                for: "comment",
                class: "block text-sm font-medium leading-6 text-gray-900"
              ) { I18n.t("time_material.comment.lbl")  }
              div(class: "mt-2") do
                div(
                  class:
                    "flex rounded-md shadow-xs ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
                ) do
                  textarea(
                    id: "time_material_comment",
                    name: "time_material[comment]",
                    rows: "3",
                    autofocus: true,
                    class:
                      "block w-full rounded-md border-0 py-1.5 px-2.5 text-gray-900 shadow-xs ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-1 focus:ring-inset focus:ring-sky-600 sm:text-sm sm:leading-6",
                    placeholder: I18n.t("time_material.comment.placeholder")
                  ) do
                    plain @time_material.comment
                  end
                end
              end
            end
            div(class: "col-span-4 grid gap-x-2 grid-cols-6") do
              div(class: "col-span-2") do
                whitespace
                label(
                  for: "quantity",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Antal" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-xs ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "time_material[quantity]",
                      id: "time_material_quantity",
                      value: @time_material.quantity,
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "900"
                    )
                  end
                end
              end
              #
              rate_field I18n.t("time_material.rate.unit_price")
              #
              div(class: "col-span-2") do
                whitespace
                label(
                  for: "discount",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { I18n.t("time_material.discount.lbl") }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-xs ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "time_material[discount]",
                      id: "time_material_discount",
                      value: @time_material.discount,
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: I18n.t("time_material.discount.placeholder")
                    )
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def about_field
    div(class: "col-span-full") do
      whitespace
      label(
        for: "time_material_about",
        class: "block text-sm font-medium leading-6 text-gray-900"
      ) { I18n.t("time_material.about.lbl") }
      div(class: "mt-2") do
        whitespace
        textarea(
          id: "time_material_about",
          name: "time_material[about]",
          rows: "3",
          autofocus: true,
          class:
            "block w-full rounded-md border-0 py-1.5 px-2.5 text-gray-900 shadow-xs ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-1 focus:ring-inset focus:ring-sky-600 sm:text-sm sm:leading-6",
          placeholder: I18n.t("time_material.about.placeholder")
        ) do
          plain @time_material.about
        end
      end
      p(class: "mt-3 text-sm leading-6 text-gray-600") do
        I18n.t("time_material.about.help")
      end
    end
  end

  def customer_field
    div(class: "mt-4 col-span-4") do
      label(for: "time_material_customer", class: "block text-sm font-medium leading-6 text-gray-900") { I18n.t("time_material.customer.lbl") }
      div(class: "mt-2") do
        div(class: "flex rounded-md shadow-xs ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md") do
          input(
            name: "time_material[customer_name]",
            id: "time_material_customer_name",
            autocomplete: "customer",
            value: @time_material.customer_name,
            class:
              "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
            placeholder: I18n.t("time_material.customer.placeholder")
          )
        end
      end
    end
  end

  def project_field
    div(class: "mt-4 col-span-4") do
      label(for: "time_material_project", class: "block text-sm font-medium leading-6 text-gray-900") { I18n.t("time_material.project.lbl") }
      div(class: "mt-2") do
        div(class: "flex rounded-md shadow-xs ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md") do
          input(
            name: "time_material[project_name]",
            id: "time_material_project_name",
            autocomplete: "project",
            value: @time_material.project_name,
            class:
              "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
            placeholder: I18n.t("time_material.project.placeholder")
          )
        end
      end
    end
  end

  def rate_field(lbl)
    div(class: "col-span-2") do
      label(for: "time_material_rate", class: "block text-sm font-medium leading-6 text-gray-900") { lbl }
      div(class: "mt-2") do
        div(
          class:
            "flex rounded-md shadow-xs ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
        ) do
          whitespace
          input(
            name: "time_material[rate]",
            id: "time_material_rate",
            value: @time_material.rate,
            class:
              "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
            placeholder: "900"
          )
        end
      end
    end
  end

  def invoicing
    div(class: "border-b border-gray-900/10 pb-12") do
      div(class: "mt-2 space-y-4") do
        fieldset do
          legend(class: "text-sm font-semibold leading-6 text-gray-900") { I18n.t("time_material.invoicing.lead") }
          div(class: "mt-6 space-y-3") do
            div(class: "relative flex gap-x-3") do
              div(class: "flex h-6 items-center") do
                input(
                  id: "time_material_is_invoice",
                  name: "time_material[is_invoice]",
                  type: "checkbox",
                  checked: @time_material.is_invoice?,
                  class: "h-4 w-4 rounded-sm border-gray-300 text-sky-600 focus:ring-sky-600"
                )
              end
              div(class: "text-sm leading-6") do
                label(for: "time_material_is_invoice", class: "font-medium text-gray-900") { I18n.t("time_material.invoicing.invoice.lbl") }
                p(class: "text-gray-500") { I18n.t("time_material.invoicing.invoice.help") }
              end
            end
            div(class: "relative flex gap-x-3") do
              div(class: "flex h-6 items-center") do
                input(
                  id: "time_material_is_free",
                  name: "time_material[is_free]",
                  type: "checkbox",
                  checked: @time_material.is_free?,
                  class: "h-4 w-4 rounded-sm border-gray-300 text-sky-600 focus:ring-sky-600"
                )
              end
              div(class: "text-sm leading-6") do
                label(for: "time_material_is_free", class: "font-medium text-gray-900") { I18n.t("time_material.invoicing.free.lbl") }
                p(class: "text-gray-500") { I18n.t("time_material.invoicing.free.help") }
              end
            end
            div(class: "relative flex gap-x-3") do
              div(class: "flex h-6 items-center") do
                input(
                  id: "time_material_is_offer",
                  name: "time_material[is_offer]",
                  type: "checkbox",
                  disabled: "disabled",
                  class: "h-4 w-4 rounded-sm border-gray-300 text-sky-600 focus:ring-sky-600"
                )
              end
              div(class: "text-sm leading-6") do
                label(for: "time_material_is_offer", class: "font-medium text-gray-900") { I18n.t("time_material.invoicing.offer.lbl") }
                p(class: "text-gray-500") { I18n.t("time_material.invoicing.offer.help") }
              end
            end
          end
        end
        fieldset do
          legend(class: "text-sm font-semibold leading-6 text-gray-900") { I18n.t("time_material.invoicing.batch.lbl") }
          div(class: "mt-6 space-y-6") do
            div(class: "relative flex gap-x-3") do
              div(class: "flex h-6 items-center") do
                input(
                  id: "time_material_is_separate",
                  name: "time_material[is_separate]",
                  type: "checkbox",
                  checked: @time_material.is_separate?,
                  class: "h-4 w-4 rounded-sm border-gray-300 text-sky-600 focus:ring-sky-600"
                )
              end
              div(class: "text-sm leading-6") do
                label(for: "time_material_is_separate", class: "font-medium text-gray-900") { I18n.t("time_material.invoicing.separate.lbl") }
                p(class: "text-gray-500") { I18n.t("time_material.invoicing.separate.help") }
              end
            end
          end
        end
      end
    end
  end

  def error_messages
    if @time_material.errors.any?
      div(id: "error_explanation", class: "mt-4 p-4 sm: p-1") do
        h2(class: "mort-err-resume") { I18n.t(:form_errors_prohibited, errors: @time_material.errors.count) }
        ul do
          @time_material.errors.each do |error|
            li { error.full_message }
          end
        end
      end
    end
  end

  def date_field
    div(class: "mt-2 sm:col-span-4") do
      label(for: "date", class: "block text-sm font-medium leading-6 text-gray-900") { I18n.t("time_material.date.lbl") }
      div(class: "mt-2") do
        div(
          class:
            "flex rounded-md shadow-xs ring-1 ring-inset ring-gray-300 focus-within:ring-1 focus-within:ring-inset focus-within:ring-sky-600 sm:max-w-md"
        ) do
          input(
            type: "date",
            name: "time_material[date]",
            id: "time_material_date",
            value: @time_material.date,
            class:
              "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6"
          )
        end
      end
    end
  end

  def form_actions
    div(class: "my-6 flex items-center justify-end gap-x-6") do
      link_to(time_materials_url, class: "mort-btn-cancel") { "Fortryd" }
      button(type: "submit", class: "mort-btn-save") { "Gem" }
    end

    # div(class: "fixed flex items-center w-screen max-w-md right-0 px-4 py-3 font-semibold text-sm text-slate-900 dark:text-slate-200 bg-slate-50 dark:bg-slate-700") do
    #   link_to(time_materials_url, class: "flex-none mr-6 rounded-md bg-slate-50 dark:bg-slate-700 text-gray-400 hover:text-gray-500 focus:outline-hidden focus:ring-1 focus:ring-sky-200 focus:ring-offset-1") do
    #     span(class: "absolute -inset-2.5")
    #     span(class: "sr-only") { "Close panel" }
    #     svg(class: "h-6 w-6", fill: "none", viewbox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", aria_hidden: "true", data_slot: "icon") do |s|
    #       s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M6 18 18 6M6 6l12 12")
    #     end
    #   end
    #   h2(class: "grow text-base font-semibold text-gray-900", id: "slide-over-title") { "Panel title" }
    #   button(type: "submit", class: "flex-none rounded-md bg-slate-50 dark:bg-slate-700 text-gray-400 hover:text-gray-500 focus:outline-hidden focus:ring-1 focus:ring-sky-200 focus:ring-offset-1") do
    #     span(class: "absolute -inset-2.5")
    #     span(class: "sr-only") { "Save content" }
    #     svg(class: "text-green-500", xmlns: "http://www.w3.org/2000/svg", height: "24px", viewbox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s|
    #       s.path(d: "M382-240 154-468l57-57 171 171 367-367 57 57-424 424Z")
    #     end
    #   end
    # end
  end
end
