class Filters::Form < ApplicationForm
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Routes

  # def initialize(filter_form:, url:)
  #   @filter_form = filter_form
  #   @url = url
  # end

  attr_accessor :resource, :cancel_url, :title, :edit_url,  :editable, :api_key, :model, :fields, :params

  def initialize(resource:, url:, filter_form:, params:, editable:, **options)
    options[:data] = { controller: "filter" }
    options[:class] = "mort-form"
    super(resource: resource, **options)
    @resource = @model = resource
    @filter_form = filter_form
    @params = params
    @fields = options[:fields] || []
    # @fields = @fields.any? ? @fields : model.class.attribute_types.keys
    @editable = editable
  end

  def view_template
    div(data_controller: "filter") do
      row field(:url).hidden value: @url
      row field(:filter_form).hidden value: @filter_form
      row field(:tenant_id).hidden value: Current.tenant.id

      div do
        tabs
        tabs_content
      end
    end
  end


  def tabs
    div(class: "sm:hidden") do
      label(for: "tabs", class: "sr-only") { "Select a tab" }
      comment do
        %(Use an "onChange" listener to redirect the user to the selected tab URL.)
      end
      select(
        id: "tabs",
        name: "tabs",
        class:
          "block mt-2 w-full rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-sky-200 focus:outline-none focus:ring-sky-200 sm:text-sm"
      ) do
        option(selected: "selected") { "Introduction" }
        option { "Date" }
        option { "Field" }
        option { "Scope" }
      end
    end
    div(class: "hidden sm:block") do
      div(class: "border-b border-gray-200") do
        nav(class: "-mb-px flex space-x-8", aria_label: "Tabs") do
          comment do
            %(Current: "border-sky-200 text-sky-200", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
          end
          a(
            href: "#",
            data_id: "introduction",
            data_action: "filter#selectTab",
            data_filter_target: "tabtitle",
            class:
              "whitespace-nowrap border-b-2 border-sky-200 px-1 py-4 text-sm font-medium text-sky-200 hover:border-gray-300 hover:text-gray-700"
          ) { "Introduction" }
          a(
            href: "#",
            data_id: "dates",
            data_action: "filter#selectTab",
            data_filter_target: "tabtitle",
            class:
              "whitespace-nowrap border-b-2 border-transparent px-1 py-4 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
            aria_current: "page"
          ) { "Date" }
          a(
            href: "#",
            data_id: "fields",
            data_action: "filter#selectTab",
            data_filter_target: "tabtitle",
            class:
              "whitespace-nowrap border-b-2 border-transparent px-1 py-4 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"
          ) { "Field" }
          a(
            href: "#",
            data_id: "scopes",
            data_action: "filter#selectTab",
            data_filter_target: "tabtitle",
            class:
              "whitespace-nowrap border-b-2 border-transparent px-1 py-4 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"
          ) { "Scope" }
        end
      end
    end
  end

  def tabs_content
    comment { "Tabs content" }
    div(class: "", data_filter_target: "tabs", id: "introduction") do
      h3(class: "mt-4 font-medium") { "Introduction to filtering" }
      p(class: "my-2") do
        "You can filter on one of the date fields in this table"
      end
      p(class: "my-2") do
        "You can filter on one/more of the fields values in this table"
      end
      p(class: "my-2") do
        "You can filter on one of the scopes in this table."
      end
      p(class: "my-2") do
        "- or you can pick one of the preset filters listed below:"
      end
      ul(class: "my-2") do
        @filter_form.classify.constantize.filter_presets.each do |preset|
          li do
            button_to I18n.t(".filter_presets.#{preset}"),
                      resources_url(
                        filter: {
                          filter_preset: preset,
                          filter_form: @filter_form,
                          url: @url
                        }
                      ),
                      class: "mort-link-primary"
          end
        end
      end
    end
    div(class: "hidden", data_filter_target: "tabs", id: "dates") do
      div do
        div(class: "flex flex-row items-center") do
          label(class: "mr-2 text-nowrap text-gray-400", for: "") do
            "Date field"
          end
          select(name: "", id: "", class: "mort-form-select mt-2") do
            option(value: "") { "date" }
            option(value: "") { "created_at" }
            option(value: "") { "updated_at" }
            option(value: "") { "invoiced_at" }
          end
        end
        label(class: "mr-2 text-gray-400", for: "") { "Period" }
        ul(class: "w-full") do
          li(class: "w-full my-1 px-3") { "Today" }
          li(class: "w-full my-1 px-3") { "Yesterday" }
          li(class: "w-full my-1 px-3") { "This week" }
          li(class: "w-full my-1 px-3") { "Last week" }
          li(class: "w-full bg-gray-100 font-bold my-1 px-3") { "This month" }
          li(class: "w-full my-1 px-3") { "Last month" }
          li(class: "w-full my-1 px-3") { "Last 3 months" }
          li(class: "w-full my-1 px-3") { "Last year" }
        end
        div(class: "px-3 mt-3") do
          h3(class: "text-gray-400") { "Custom" }
          div(class: "grid items-center") do
            div(class: "flex columns-2 items-center") do
              label(class: "mr-2 grow", for: "") { "from" }
              input(type: "date", class: "mort-form-text w-3/4")
            end
            div(class: "flex columns-2 items-center") do
              label(class: "mr-2 grow", for: "") { "to" }
              input(type: "date", class: "mort-form-text w-3/4")
            end
          end
        end
      end
    end
    div(class: "hidden", data_filter_target: "tabs", id: "fields") do
      ul(role: "list", class: "-mx-2 mt-2 space-y-1") do
        li do
          comment { %(Current: "bg-gray-50", Default: "hover:bg-gray-50") }
          a(
            href: "#",
            class:
              "block rounded-md bg-gray-50 py-2 pl-10 pr-2 text-sm font-semibold leading-6 text-gray-700"
          ) { "ID" }
        end
        li do
          div do
            button(
              type: "button",
              class:
                "flex w-full items-center gap-x-3 rounded-md p-2 text-left text-sm font-semibold leading-6 text-gray-700 hover:bg-gray-50",
              aria_controls: "sub-menu-1",
              aria_expanded: "false"
            ) do
              comment do
                %(Expanded: "rotate-90 text-gray-500", Collapsed: "text-gray-400")
              end
              svg(
                class: "h-5 w-5 rotate-90 shrink-0 text-gray-400",
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
              plain " Customer "
            end
            comment { "Expandable link section, show/hide based on state." }
            ul(class: "mt-1 px-2", id: "sub-menu-1") do
              li(class: "bg-sky-100 rounded-md") do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-sky-600 hover:bg-gray-50"
                ) { "Name" }
              end
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "Street" }
              end
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "City" }
              end
            end
          end
        end
        li do
          div do
            button(
              type: "button",
              class:
                "flex w-full items-center gap-x-3 rounded-md p-2 text-left text-sm leading-6 text-gray-700 hover:bg-gray-50",
              aria_controls: "sub-menu-2",
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
              plain " Project "
            end
            comment { "Expandable link section, show/hide based on state." }
            ul(class: "hidden mt-1 px-2", id: "sub-menu-2") do
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "GraphQL API" }
              end
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "iOS App" }
              end
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "Android App" }
              end
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "New Customer Portal" }
              end
            end
          end
        end
        li do
          div do
            button(
              type: "button",
              class:
                "flex w-full items-center gap-x-3 rounded-md p-2 text-left text-sm leading-6 text-gray-700 hover:bg-gray-50",
              aria_controls: "sub-menu-2",
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
              plain " Product "
            end
            comment { "Expandable link section, show/hide based on state." }
            ul(class: "hidden mt-1 px-2", id: "sub-menu-2") do
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "name" }
              end
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "iOS App" }
              end
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "Android App" }
              end
              li do
                a(
                  href: "#",
                  class:
                    "block rounded-md py-2 pl-9 pr-2 text-sm leading-6 text-gray-700 hover:bg-gray-50"
                ) { "New Customer Portal" }
              end
            end
          end
        end
        li(class: "border border-sky-200 rounded-md") do
          a(
            href: "#",
            class:
              "block rounded-md py-2 pl-10 pr-2 text-sm font-semibold leading-6 text-gray-700 hover:bg-gray-50"
          ) { "About" }
        end
        li do
          a(
            href: "#",
            class:
              "block rounded-md py-2 pl-10 pr-2 text-sm font-semibold leading-6 text-gray-700 hover:bg-gray-50"
          ) { "Time" }
        end
        li do
          a(
            href: "#",
            class:
              "block rounded-md py-2 pl-10 pr-2 text-sm font-semibold leading-6 text-gray-700 hover:bg-gray-50"
          ) { "Rate" }
        end
        li do
          a(
            href: "#",
            class:
              "block rounded-md py-2 pl-10 pr-2 text-sm font-semibold leading-6 text-gray-700 hover:bg-gray-50"
          ) { "Quantity" }
        end
        li do
          a(
            href: "#",
            class:
              "block rounded-md py-2 pl-10 pr-2 text-sm font-semibold leading-6 text-gray-700 hover:bg-gray-50"
          ) { "Unit" }
        end
      end
    end
    div(class: "hidden mt-4", data_filter_target: "tabs", id: "scopes") do
      comment do
        "This example requires some changes to your config: ``` // tailwind.config.js module.exports = { // ... plugins: [ // ... require('@tailwindcss/forms'), ], } ```"
      end
      fieldset do
        legend(class: "text-sm font-semibold leading-6 text-gray-900") do
          "User"
        end
        p(class: "mt-1 text-sm leading-6 text-gray-600") do
          "Whose transactions would you like to see?"
        end
        div(class: "mt-3 space-y-4") do
          div(class: "flex items-center") do
            input(
              id: "email",
              name: "notification-method",
              type: "radio",
              checked: "checked",
              class: "h-4 w-4 border-gray-300 text-sky-200 focus:ring-sky-200"
            )
            label(
              for: "email",
              class: "ml-3 block text-sm font-medium leading-6 text-gray-900"
            ) { "Mine" }
          end
          div(class: "flex items-center") do
            input(
              id: "sms",
              name: "notification-method",
              type: "radio",
              class: "h-4 w-4 border-gray-300 text-sky-200 focus:ring-sky-200"
            )
            label(
              for: "sms",
              class: "ml-3 block text-sm font-medium leading-6 text-gray-900"
            ) { "Those of my team" }
          end
          div(class: "flex items-center") do
            input(
              id: "push",
              name: "notification-method",
              type: "radio",
              class: "h-4 w-4 border-gray-300 text-sky-200 focus:ring-sky-200"
            )
            label(
              for: "push",
              class: "ml-3 block text-sm font-medium leading-6 text-gray-900"
            ) { "Everybody's" }
          end
          input(class: "mort-form-text", placeholder: "named users/teams")
        end
      end
      div(class: "mt-4") do
        label(for: "", class: "text-sm") { "Customers" }
        select(name: "", id: "", class: "mort-form-text") do
          option(value: "") { "Sindico" }
        end
      end
      div(class: "mt-4") do
        label(for: "", class: "text-sm") { "Projects" }
        select(name: "", id: "", class: "mort-form-text") do
          option(value: "") { "Cloud-mg" }
        end
      end
      div(class: "mt-4") do
        label(for: "", class: "text-sm") { "Products" }
        select(name: "", id: "", class: "mort-form-text") do
          option(value: "") { "web-hosting" }
        end
      end
    end
  end
end
