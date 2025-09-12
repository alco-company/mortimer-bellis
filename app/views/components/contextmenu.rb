class Contextmenu < ApplicationComponent
  include Phlex::Rails::Helpers::Request
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  # include Rails.application.routes.url_helpers

  attr_accessor :resource, :resource_class, :list

  def initialize(resource: nil, list: nil, resource_class: nil, turbo_frame: "_top", alter: true, links: [], cls: "relative flex", filter: nil, user: nil, show_all: "false")
    @resource = resource
    @resource_class = resource_class || resource.class
    @list = list
    @turbo_frame = turbo_frame
    @alter = alter
    @filter = filter
    @links = links
    @css = cls
    @user = user
    @show_all = show_all != "false"            # particular to TimeMaterial - show all or only my unfinished time materials
  end

  def view_template
    div(data_controller: "contextmenu", class: @css) do
      contextmenu_button
      case true
      when !list.nil?; list_dropdown
      when !resource.nil?; dropdown
      end
    end
  end

  def contextmenu_button
    # resource.respond_to?(:archived?) && resource.archived? ? archived_button : more_button
    more_button
  end

  def archived_button
    a_button(css: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
      label: t("more"),
      visible_label: true) do
        svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "#5f6368") do |s|
          s.path(d: "M200-80q-33 0-56.5-23.5T120-160v-451q-18-11-29-28.5T80-680v-120q0-33 23.5-56.5T160-880h640q33 0 56.5 23.5T880-800v120q0 23-11 40.5T840-611v451q0 33-23.5 56.5T760-80H200Zm0-520v440h560v-440H200Zm-40-80h640v-120H160v120Zm200 280h240v-80H360v80Zm120 20Z")
        end
      end
  end

  def more_button
    list.nil? ? more_button_single : more_button_list
  end

  def more_button_list
    a_button css: "flex items-center rounded-md ring-0 sm:ring-1 ring-gray-100 pl-3 pr-1 py-1 mr-1 text-gray-400 hover:text-gray-600 focus:outline-hidden focus:ring-1 focus:ring-sky-500",
      label: t("more"),
      visible_label: true
  end

  def more_button_single
    a_button css: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900", label: nil
  end

  def list_dropdown
    # Dropdown menu, show/hide based on menu state.
    #
    #  Entering: "transition ease-out duration-100"
    #    From: "transform opacity-0 scale-95"
    #    To: "transform opacity-100 scale-100"
    #  Leaving: "transition ease-in duration-75"
    #    From: "transform opacity-100 scale-100"
    #    To: "transform opacity-0 scale-95"
    div(
      data: {
        contextmenu_target: "popup",
        transition_enter: "transition ease-out duration-300",
        transition_enter_start: "transform opacity-0 scale-95",
        transition_enter_end: "transform opacity-100 scale-100",
        transition_leave: "transition ease-in duration-75",
        transition_leave_start: "transform opacity-100 scale-100",
        transition_leave_end: "transform opacity-0 scale-95"
      },
      class: "hidden absolute right-0 z-10 mt-2 w-56 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-slate-100 focus:outline-hidden",
      role: "menu",
      aria_orientation: "vertical",
      aria_labelledby: "options-menu-0-button",
      tabindex: "-1"
    ) do
      #  Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700"
      unless resource_class.to_s == "Setting"
        link2(url: filtering_url(), data: { action: "click->contextmenu#hide", turbo_frame: "form" }, label: t("filters.title"), icon: "filter")
        a_button action: "click->list#toggleBatch click->contextmenu#hide", css: "flex justify-between w-full px-4 py-2 text-sm text-gray-700 hover:text-gray-900" do
          render_icon "select"
          span { t(".batch") }
        end
      end

      # if resource_class.to_s == "TimeMaterial"
      #   current_param = request.query_parameters.dig(:show_all)
      #   current = ActiveModel::Type::Boolean.new.cast(current_param)
      #   base = request.query_parameters.symbolize_keys
      #   if current
      #     lbl = t(".toggle_show_my_unfinished")
      #     url = resources_url(**base.merge(show_all: false, replace: true))
      #   else
      #     lbl = t(".toggle_show_all")
      #     url = resources_url(**base.merge(show_all: true, replace: true))
      #   end
      #   link2 url: url,
      #     data: { action: "click->contextmenu#toggle_show_all", href: url, turbo_frame: @turbo_frame },
      #     label: lbl,
      #     icon: "reload"
      # end

      resource_class.any? && resource_class.to_s != "Setting" ?
        link2(url: new_modal_url(modal_form: "delete",
          all: true,
          resource_class: resource_class.to_s.underscore,
          modal_next_step: "accept",
          search: request.query_parameters.dig(:search)),
          action: "click->contextmenu#hide",
          icon: "trash",
          label: t(".delete_all")) :
        div(class: "flex justify-between px-4 py-2 text-sm text-gray-700 hover:text-gray-900") do
          render_icon "trash"
          div(class: "text-nowrap text-gray-400 pl-2") { t(".delete_all") }
        end if resource_class.to_s != "Setting"
      hr
      # link2(url: new_modal_url(modal_form: "import", resource_class: resource_class.to_s.underscore, modal_next_step: "preview"),
      #   action: "click->contextmenu#hide",
      #   label: t(".import")) if resource_class.to_s == "User"
      show_ERP_link

      show_mission_control_link
      toggle_jobs

      link2 url: new_modal_url(modal_form: "settings",
        all: true,
        resource_class: resource_class.to_s.underscore,
        modal_next_step: "setup"),
        # search: request.query_parameters.dig(:search)),
        action: "click->contextmenu#hide",
        icon: "setting",
        label: t("settings.label")

      link2 url: new_modal_url(modal_form: "export",
        all: true,
        resource_class: resource_class.to_s.underscore,
        modal_next_step: "setup",
        search: request.query_parameters.dig(:search)),
        action: "click->contextmenu#hide",
        icon: "download",
        label: t(".export")
      # link2 url: resources_url() + ".csv",
      #   data: { turbo_frame: "_top" },
      #   icon: "download",
      #   label: t(".export")
      # link2 url: resources_url() + ".pdf",
      #   data: { turbo_frame: "_top" },
      #   icon: "pdf",
      #   label: t(".pdf")
    end
  end

  def dropdown
    return unless @alter
    comment do
      %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
    end
    div(
      data: {
        contextmenu_target: "popup",
        transition_enter: "transition ease-out duration-300",
        transition_enter_start: "transform opacity-0 scale-95",
        transition_enter_end: "transform opacity-100 scale-100",
        transition_leave: "transition ease-in duration-75",
        transition_leave_start: "transform opacity-100 scale-100",
        transition_leave_end: "transform opacity-0 scale-95"
      },
      class:
        "hidden top-0 list_context_menu",
      role: "menu",
      aria_orientation: "vertical",
      aria_labelledby: "options-menu-0-button",
      tabindex: "-1"
    ) do
      comment { %(Active: "bg-gray-50", Not Active: "") }
      # archive employee
      # on roadmap for now
      # if resource_class.to_s == "User" || (resource_class.to_s == "TimeMaterial" && (resource.pushed_to_erp? || resource.archived?))
      #   button_to((archive_resource_url(resource)),
      #     class: "flex justify-between px-4 py-2 text-sm text-gray-700 mb-0",
      #     role: "menuitem",
      #     data: { turbo_action: "advance", turbo_frame: "_top" },
      #     tabindex: "-1") do
      #     resource.archived? ?
      #       plain(t(".unarchive")) :
      #       plain(t(".archive"))
      #     span(class: "sr-only") do
      #       plain ", "
      #       plain resource.name rescue ""
      #     end
      #   end
      # end
      # edit resource
      link2(url: (@links[0] || edit_resource_url(id: resource.id)),
        data: { turbo_action: "advance", turbo_frame: @turbo_frame },
        icon: "edit",
        label: t(".edit")) unless (resource_class.to_s == "TimeMaterial" && resource.pushed_to_erp?) || resource.respond_to?(:archived?) && resource.archived?
      # copy resource
      link2(url: copy_resource_url(id: resource.id),
        data: { turbo_action: "advance", turbo_frame: @turbo_frame },
        icon: "copy",
        label: t(".copy")) if resource_class.to_s == "TimeMaterial"
      # delete resource
      link2(url: erp_pull_link,
        data: { turbo_prefetch: "false" },
        action: "click->contextmenu#hide",
        icon: "ArrowsHunting",
        label: t(".sync all with ERP")) if erp_pull_link && %(ProvidedService).include?(resource_class.to_s)

      setting_link unless resource_class.to_s == "TimeMaterial"
      delete_record
    end
  end

  # link_to t("Mission Control Jobs"), "/solid_queue_jobs", class: "mort-link-primary", data: { turbo_prefetch: "false" }
  def show_mission_control_link
    return unless resource_class.to_s == "BackgroundJob" && @user.superadmin?
    link2target url: "/solid_queue_jobs",
      target: "_blank",
      data: { turbo_prefetch: "false", turbo: false, turbo_frame: "_blank" },
      icon: "link",
      label: t("mission_control_jobs")
  end

  def toggle_jobs
    return unless resource_class.to_s == "BackgroundJob" && @user.superadmin?
    tf = "toggle_background_jobs"
    link2frame url: toggle_background_jobs_url(turbo_frame: tf, partial: "background_jobs/toggle"),
      data: { turbo_stream: true, turbo_frame: tf },
      icon: "background_job",
      turbo_frame: tf,
      label: show_background_job_toggle_label
  end

  def show_background_job_toggle_label
    if Tenant.first.background_jobs.build.shouldnt? :run
      t("settings.run.start")
    else
      t("settings.run.stop")
    end
  end




  def setting_link
    link2 url: new_modal_url(modal_form: "settings",
      id: resource.id,
      resource_class: resource_class.to_s.underscore,
      modal_next_step: "setup"),
      # search: request.query_parameters.dig(:search)),
      action: "click->contextmenu#hide",
      icon: "setting",
      label: t("settings.label")
  end

  def delete_record
    if (resource_class.to_s == "User" && resource == Current.user) ||
      (resource_class.to_s == "Tenant" && Current.tenant == resource) ||
      (resource_class.to_s == "TimeMaterial" && resource.pushed_to_erp?)
      span(class: "block px-3 py-1 text-sm leading-6 text-gray-400") do
        plain t(".delete")
      end
    else
      link2 url: new_modal_url(modal_form: "delete", id: resource.id, resource_class: resource_class.to_s.underscore, modal_next_step: "accept", url: @links[1]),
        label: t(".delete"), icon: "trash"
    end
  end

  private

    def should_show_ERP_sync_link?
      (Current.get_tenant.provided_services.by_name("Dinero").any? and
      Current.get_tenant.license_valid? and
      %W[trial ambassador pro].include? Current.get_tenant.license and
      @user.can?(:sync_with_erp, resource: resource_class))
    end

    def show_ERP_link
      if should_show_ERP_sync_link?
        link2(url: new_modal_url(modal_form: "upload_dinero",
          resource_class: resource_class.to_s.underscore,
          search: request.query_parameters.dig(:search),
          modal_next_step: "preview"),
          action: "click->contextmenu#hide",
          icon: "ArrowsHunting",
          label: t(".upload to ERP")) if resource_class.to_s == "TimeMaterial"
        link2(url: erp_pull_link,
          data: { turbo_prefetch: "false" },
          action: "click->contextmenu#hide",
          icon: "ArrowsHunting",
          label: t(".sync with ERP")) if %(Customer Product Invoice).include? resource_class.to_s
      else
        if %(Customer Product Invoice TimeMaterial).include? resource_class.to_s
          div(class: "flex justify-between px-4 py-2 text-sm text-gray-400") do
            render_icon "ArrowsHunting"
            span(class: "text-nowrap pl-2 truncate") { t(".sync with ERP") } if resource_class.to_s == "TimeMaterial"
            span(class: "text-nowrap pl-2 truncate") { t(".sync with ERP") } if %(Customer Product Invoice).include? resource_class.to_s
            # div(class: "block px-3 py-1 text-sm leading-6 text-gray-400") { t(".upload to ERP") } if resource_class.to_s == "TimeMaterial"
            # div(class: "block px-3 py-1 text-sm leading-6 text-gray-400") { t(".sync with ERP") } if %(Customer Product Invoice).include? resource_class.to_s
          end
        end
      end
    end

    def link2(url:, label:, action: nil, data: { turbo_stream: true }, icon: nil, css: "flex justify-between px-4 py-2 text-sm text-gray-700 hover:text-gray-900")
      data[:action] = action if action
      link_to url,
        data: data,
        class: css,
        role: "menuitem",
        tabindex: "-1" do
        render_icon icon
        span(class: "text-nowrap pl-2") { label }
        span(class: "sr-only") do
          plain label
          plain " "
          plain resource.name rescue ""
        end
      end
    end

    def link2target(url:, label:, target: nil, data: { turbo_stream: true }, icon: nil, css: "flex justify-between px-4 py-2 text-sm text-gray-700 hover:text-gray-900")
      link_to url,
        data: data,
        class: css,
        role: "menuitem",
        target: target,
        tabindex: "-1" do
        render_icon icon
        span(class: "text-nowrap pl-2") { label }
        span(class: "sr-only") do
          plain label
          plain " "
          plain resource.name rescue ""
        end
      end
    end

    def link2frame(url:, label:, turbo_frame: nil, target: nil, data: { turbo_stream: true }, icon: nil, css: "flex justify-between px-4 py-2 text-sm text-gray-700 hover:text-gray-900")
      turbo_frame_tag turbo_frame do
        link_to url,
          data: data,
          class: css,
          role: "menuitem",
          target: target,
          tabindex: "-1" do
          render_icon icon
          span(class: "text-nowrap pl-2") { label }
          span(class: "sr-only") do
            plain label
            plain " "
            plain resource.name rescue ""
          end
        end
      end
    end

    def a_button(
      css: "flex items-center rounded-md ring-1 ring-gray-100 bg-transparent px-2 py-1 text-gray-400 hover:text-gray-600 focus:outline-hidden focus:ring-1 focus:ring-sky-500",
      label: t("more"),
      visible_label: false,
      data: { contextmenu_target: "button" },
      action: "touchstart->contextmenu#tap:passive click->contextmenu#tap click@window->contextmenu#hide", &block)
      data[:action] = action if action
      button(
        type: "button",
        data: data,
        class: css,
        # "flex items-center p-1 text-gray-400 rounded-md hover:text-gray-900 border h-7 -mr-0.5 pl-3",
        # ,
        # id: "options-menu-0-button",
        aria_expanded: "false",
        aria_haspopup: "true"
      ) do
        if block_given?
          yield
        else
          span(class: "sr-only") { "Open list options" }
          span(class: "text-2xs hidden sm:inline") { label } if visible_label
          render Icons::More.new if @alter
        end
      end
    end

    def render_icon(icon)
      return if icon.blank?
      render "Icons::#{icon.camelcase}".constantize.new(css: "h-4 w-4 text-gray-400")
    end

    def erp_pull_link
      case resource_class.to_s
      when "Customer"; erp_pull_customers_url if @user.can?(:sync_with_erp, resource: Customer) && @user.can?(:pull_customers, resource: Customer)
      when "Product"; erp_pull_products_url if @user.can?(:sync_with_erp, resource: Product) && @user.can?(:pull_products, resource: Product)
      when "Invoice"; erp_pull_invoices_url if @user.can?(:sync_with_erp, resource: Invoice) && @user.can?(:pull_invoices, resource: Invoice)
      when "ProvidedService"; erp_pull_provided_services_url if @user.can?(:sync_with_erp, resource: ProvidedService) && @user.can?(:pull_provided_services, resource: ProvidedService)
      end
    end

    def filtering_url
      @filter.persisted? ?
        edit_filter_url(@filter, url: resources_url, filter_form: params_ctrl.split("/").last):
        new_filter_url(url: resources_url, filter_form: params_ctrl.split("/").last)
    end


    # def archive_resource_url(resource)
    #   case resource.class.name
    #   when "User"; archive_user_url(resource)
    #   when "TimeMaterial"; archive_time_material_url(resource)
    #   else; ""
    #   end
    # end # rubocop:disable Layout/CommentIndentation
end
