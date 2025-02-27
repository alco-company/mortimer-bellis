class TimeMaterialHeader < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  attr_reader :resources, :resource_class, :title

  def initialize(resources:, resource_class:, title: nil, context: nil)
    @resources = resources
    @resource_class = resource_class
    @title = title || I18n.t("#{resource_class.table_name}.list.title")
    @context = context
  end

  def view_template
    div(class: "px-2 flex flex-row min-h-10 mb-2") do
      # title and filtered, more
      div(class: "basis-4/5") do
        div(
          class: "flex flex-wrap gap-x-4 font-bold lg:text-xl items-center"
        ) do
          # image - contacts, users, teams, products, locations, etc
          # img(
          #   src: "https://tailwindui.com/plus/img/logos/48x48/tuple.svg",
          #   alt: "",
          #   class:
          #     "h-16 w-16 flex-none rounded-full ring-1 ring-gray-900/10"
          # )
          h1 do
            # context
            if @context
              div(class: "hidden text-xs text-gray-500") do
                plain "Invoice "
                span(class: "text-gray-700") { "#00011" }
              end
            end

            # title and filtered, sorted, more
            div(class: "flex flex-wrap mt-1 text-base font-semibold text-gray-900 max-w-1/4 items-center") do
              span(class: "mr-2 text-2xl") { title }
              short_cuts
              # filtered
              # sorted
              filtered
              sorted
            end
          end
        end
      end

      div(class: "flex gap-x-2 gap-y-2 mr-2 flex-wrap basis-1/3 justify-end content-end sm:content-center") do
        case resource_class.table_name
        when "users"; link_to("Invite New User", users_invitations_new_url, class: "mort-btn-primary", role: "menuitem", tabindex: "-1", id: "user-menu-item-0") unless Current.user.user?
        else
          # Add button
          link_to helpers.new_resource_url, class: "mort-btn-primary", data: { turbo_frame: "form" } do
            svg(
              class: "text-white h-4",
              xmlns: "http://www.w3.org/2000/svg",
              viewbox: "0 -960 960 960",
              fill: "currentColor"
            ) do |s|
              s.path(
                d: "M440-440H200v-80h240v-240h80v240h240v80H520v240h-80v-240Z"
              )
            end
            span(class: "hidden lg:inline") { I18n.t("#{ resource_class.table_name}.list.new") }
          end
        end

        #     <div class="hidden md:block mr-2 justify-end">
        #       <%== pagy_nav(@pagy) if @pagy.pages > 1 %>
        #     </div>

        # List Context Menu
        # render_contextmenu list: @resources, resource_class: resource_class
        render Contextmenu.new list: resources, resource_class: resource_class
      end
    end
  end

  def short_cuts
    case @filter_form
    when "customers";     link_to t(".sync_with_ERP"), erp_pull_customers_url, class: "mort-link-primary", data: { turbo_prefetch: "false" }
    when "products";      link_to t(".sync_with_ERP"), erp_pull_products_url, class: "mort-link-primary", data: { turbo_prefetch: "false" }
    when "invoices";      link_to t(".sync_with_ERP"), erp_pull_invoices_url, class: "mort-link-primary", data: { turbo_prefetch: "false" }
    when "punch_cards"
                          link_to t(:payroll_order), new_modal_url(modal_form: "payroll", resource_class: "punch_card"), class: "inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10", data: { turbo_stream: true }
                          link_to t(:state_order), new_modal_url(modal_form: "state", resource_class: "punch_card"), class: "inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10", data: { turbo_stream: true }
    when "users";         link_to_user_status
    # link_to t("user_invitations.link"), user_invitations_url, class: "inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10", data: { turbo_stream: true }
    when "teams";         link_to_team_users_status("all")
    end
  end

  def filtered
    span(class: "mr-3 inline-flex items-center rounded-md bg-sky-400 px-2 py-1 text-xs font-medium text-gray-100 ring-1 ring-inset ring-gray-500/10") do
      plain " filtered "
      span(class: "sr-only") { "Close" }
      svg(
        class: "h-4 ml-3",
        fill: "none",
        viewbox: "0 0 24 24",
        stroke_width: "1.5",
        stroke: "currentColor",
        aria_hidden: "true"
      ) do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          d: "M6 18L18 6M6 6l12 12"
        )
      end
    end
  end

  def sorted
    span(class: "mr-3 inline-flex items-center rounded-md bg-sky-400 px-2 py-1 text-xs font-medium text-gray-100 ring-1 ring-inset ring-gray-500/10") do
      plain " sorted "
      span(class: "sr-only") { "Close" }
      svg(
        class: "h-4 ml-3",
        fill: "none",
        viewbox: "0 0 24 24",
        stroke_width: "1.5",
        stroke: "currentColor",
        aria_hidden: "true"
      ) do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          d: "M6 18L18 6M6 6l12 12"
        )
      end
    end
  end
end
