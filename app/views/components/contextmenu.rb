class Contextmenu < Phlex::HTML
  include Phlex::Rails::Helpers::Request
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Rails.application.routes.url_helpers

  attr_accessor :resource, :resource_class, :list

  def initialize(resource: nil, list: nil, resource_class: nil, turbo_frame: "_top", alter: true, links: [], cls: "relative flex")
    @resource = resource
    @resource_class = resource_class || resource.class
    @list = list
    @turbo_frame = turbo_frame
    @alter = alter
    @links = links
    @css = cls
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
    resource.respond_to?(:archived?) && resource.archived? ? archived_button : more_button
  end

  def archived_button
    a_button(css: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
      label: I18n.t("more"),
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
    a_button css: "flex items-center rounded-md ring-1 ring-gray-100 px-2 py-1 text-gray-400 hover:text-gray-600 focus:outline-hidden focus:ring-1 focus:ring-sky-500",
      label: I18n.t("more"),
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
      link2 url: helpers.filtering_url(), data: { action: "click->contextmenu#hide", turbo_frame: "form" }, label: I18n.t("filters.title")
      a_button action: "click->list#toggleBatch click->contextmenu#hide", css: "flex justify-between px-4 py-2 text-sm text-gray-700 hover:text-gray-900" do
        plain I18n.t(".batch")
      end

      resource_class.any? ?
        link2(url: helpers.new_modal_url(modal_form: "delete",
          all: true,
          resource_class: resource_class.to_s.underscore,
          modal_next_step: "accept",
          search: request.query_parameters.dig(:search)),
          action: "click->contextmenu#hide",
          label: I18n.t(".delete_all")) :
        div(class: "block px-3 py-1 text-sm leading-6 text-gray-400") { I18n.t(".delete_all") }
      hr
      # link2(url: helpers.new_modal_url(modal_form: "import", resource_class: resource_class.to_s.underscore, modal_next_step: "preview"),
      #   action: "click->contextmenu#hide",
      #   label: I18n.t(".import")) if resource_class.to_s == "User"
      link2(url: helpers.new_modal_url(modal_form: "upload_dinero",
        resource_class: resource_class.to_s.underscore,
        search: request.query_parameters.dig(:search),
        modal_next_step: "preview"),
        action: "click->contextmenu#hide",
        label: I18n.t(".upload to ERP")) if resource_class.to_s == "TimeMaterial"
      link2 url: helpers.resources_url() + ".csv",
        data: { turbo_frame: "_top" },
        label: I18n.t(".export")
      link2 url: helpers.resources_url() + ".pdf",
        data: { turbo_frame: "_top" },
        label: I18n.t(".pdf")
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
      if resource_class.to_s == "User" || (resource_class.to_s == "TimeMaterial" && (resource.pushed_to_erp? || resource.archived?))
        button_to((helpers.archive_resource_url(resource)),
          class: "flex justify-between px-4 py-2 text-sm text-gray-700 mb-0",
          role: "menuitem",
          data: { turbo_action: "advance", turbo_frame: "_top" },
          tabindex: "-1") do
          resource.archived? ?
            plain(I18n.t(".unarchive")) :
            plain(I18n.t(".archive"))
          span(class: "sr-only") do
            plain ", "
            plain resource.name rescue ""
          end
        end
      end
      # edit resource
      link2(url: (@links[0] || helpers.edit_resource_url(id: resource.id)),
        data: { turbo_action: "advance", turbo_frame: @turbo_frame },
        label: I18n.t(".edit")) unless (resource_class.to_s == "TimeMaterial" && resource.pushed_to_erp?) || resource.respond_to?(:archived?) && resource.archived?
      # delete resource
      delete_record
    end
  end

  def delete_record
    if (resource_class.to_s == "User" && resource == Current.user) ||
      (resource_class.to_s == "Tenant" && Current.tenant == resource) ||
      (resource_class.to_s == "TimeMaterial" && resource.pushed_to_erp?)
      span(class: "block px-3 py-1 text-sm leading-6 text-gray-400") do
        plain I18n.t(".delete")
      end
    else
      link2 url: helpers.new_modal_url(modal_form: "delete", id: resource.id, resource_class: resource_class.to_s.underscore, modal_next_step: "accept", url: @links[1]),
        label: I18n.t(".delete")
    end
  end

  private

    def link2(url:, label:, action: nil, data: { turbo_stream: true }, css: "flex justify-between px-4 py-2 text-sm text-gray-700 hover:text-gray-900")
      data[:action] = action if action
      link_to url,
        data: data,
        class: css,
        role: "menuitem",
        tabindex: "-1" do
        plain label
        span(class: "sr-only") do
          plain label
          plain " "
          plain resource.name rescue ""
        end
      end
    end

    def a_button(
      css: "flex items-center rounded-md ring-1 ring-gray-100 bg-transparent px-2 py-1 text-gray-400 hover:text-gray-600 focus:outline-hidden focus:ring-1 focus:ring-sky-500",
      label: I18n.t("more"),
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
end
