class Contextmenu < Phlex::HTML
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
    @cls = cls
  end

  def view_template
    div(data_controller: "contextmenu", class: @cls) do
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
    button(
      type: "button",
      data_contextmenu_target: "button",
      data_action: "touchstart->contextmenu#tap click->contextmenu#tap click@window->contextmenu#hide",
      class: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
      id: "options-menu-0-button",
      aria_expanded: "false",
      aria_haspopup: "true"
    ) do
      svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "#5f6368") do |s|
        s.path(d: "M200-80q-33 0-56.5-23.5T120-160v-451q-18-11-29-28.5T80-680v-120q0-33 23.5-56.5T160-880h640q33 0 56.5 23.5T880-800v120q0 23-11 40.5T840-611v451q0 33-23.5 56.5T760-80H200Zm0-520v440h560v-440H200Zm-40-80h640v-120H160v120Zm200 280h240v-80H360v80Zm120 20Z")
      end
    end
  end

  def more_button
    list.nil? ? more_button_single : more_button_list
  end

  def more_button_list
    button(
      type: "button",
      data_contextmenu_target: "button",
      data_action:
        " touchstart->contextmenu#tap click->contextmenu#tap click@window->contextmenu#hide",
      class:
        # "flex items-center p-1 text-gray-400 rounded-md hover:text-gray-900 border h-7 -mr-0.5 pl-3",
        "flex items-center rounded-md ring-1 ring-gray-100 bg-white px-2 py-1 text-gray-400 hover:text-gray-600 focus:outline-none focus:ring-1 focus:ring-sky-500",
      id: "options-menu-0-button",
      aria_expanded: "false",
      aria_haspopup: "true"
    ) do
      span(class: "sr-only") { "Open list options" }
      span(class: "text-2xs hidden sm:inline") { I18n.t("more") }
      render Icons::More.new
    end
  end

  def more_button_single
    button(
      type: "button",
      data_contextmenu_target: "button",
      data_action: "touchstart->contextmenu#tap click->contextmenu#tap click@window->contextmenu#hide",
      class: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
      id: "options-menu-0-button",
      aria_expanded: "false",
      aria_haspopup: "true"
    ) do
      span(class: "sr-only") { "Open #{list.nil? ? "item " : "list "}options" }
      render Icons::More.new if @alter
    end
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
      class: "hidden absolute right-0 z-10 mt-2 w-56 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
      role: "menu",
      aria_orientation: "vertical",
      aria_labelledby: "options-menu-0-button",
      tabindex: "-1"
    ) do
      #  Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700"
      link_to helpers.filtering_url(),
        data: { turbo_stream: true, action: "click->contextmenu#hide" },
        class: "flex justify-between px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1" do
        plain I18n.t(".filter")
        span(class: "sr-only") do
          plain ", "
          plain "filter"
        end
      end
      link_to helpers.filtering_url(),
        data: { turbo_stream: true, action: "click->contextmenu#hide" },
        class: "flex justify-between px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1" do
        plain I18n.t(".sort")
        span(class: "sr-only") do
          plain ", "
          plain "sort"
        end
      end
      # link_to helpers.filtering_url(),
      #   data: { turbo_stream: true, action: "click->contextmenu#hide" },
      #   class: "flex justify-between px-4 py-2 text-sm text-gray-700",
      #   role: "menuitem",
      #   tabindex: "-1" do
      #   plain I18n.t(".select")
      #   span(class: "sr-only") do
      #     plain ", "
      #     plain "select"
      #   end
      # end

      resource_class.any? ?
        link_to(
          helpers.new_modal_url(modal_form: "delete", resource_class: resource_class.to_s.underscore, modal_next_step: "accept"),
          disabled: true,
          data: { turbo_stream: true },
          # link_to helpers.delete_all_url(),
          # data: { turbo_method: :delete, turbo_confirm: "Are you sure?", turbo_stream: true, action: "click->contextmenu#hide" },
          class: "flex justify-between px-4 py-2 text-sm text-gray-700",
          role: "menuitem",
          tabindex: "-1") do
          plain I18n.t(".delete_all")
          span(class: "sr-only") do
            plain ", "
            plain "delete all"
          end
        end :
        div(class: "block px-3 py-1 text-sm leading-6 text-gray-400") { I18n.t(".delete_all") }
      hr
      link_to(
        helpers.new_modal_url(modal_form: "import", resource_class: resource_class.to_s.underscore, modal_next_step: "preview"),
        class: "flex justify-between px-4 py-2 text-sm text-gray-700",
        data: { turbo_stream: true }
        ) do
        plain I18n.t(".import")
        span(class: "sr-only") do
          plain ", "
          plain "import"
        end
      end if resource_class.to_s == "User"
      link_to(
        helpers.new_modal_url(modal_form: "upload_dinero", resource_class: resource_class.to_s.underscore, modal_next_step: "preview"),
        class: "flex justify-between px-4 py-2 text-sm text-gray-700",
        data: { turbo_stream: true }
        ) do
        plain I18n.t(".upload to ERP")
        span(class: "sr-only") do
          plain ", "
          plain "import"
        end
      end if resource_class.to_s == "TimeMaterial"
      link_to(
        helpers.resources_url() + ".csv",
        class: "flex justify-between px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        data: { turbo_frame: "_top" }) do
        plain I18n.t(".export")
        span(class: "sr-only") do
          plain ", "
          plain "export"
        end
      end
      whitespace
      link_to(
        helpers.resources_url() + ".pdf",
        class: "flex justify-between px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        tabindex: "-1",
        data: { turbo_frame: "_top" }) do
        plain I18n.t(".pdf")
        span(class: "sr-only") do
          plain ", "
          plain "pdf"
        end
      end
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
        "hidden absolute right-0 z-10 mt-2 w-auto min-w-18 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-none",
      role: "menu",
      aria_orientation: "vertical",
      aria_labelledby: "options-menu-0-button",
      tabindex: "-1"
    ) do
      comment { %(Active: "bg-gray-50", Not Active: "") }
      # archive employee
      if resource_class.to_s == "User" || (resource_class.to_s == "TimeMaterial" && (resource.pushed_to_erp? || resource.archived?))
        button_to((helpers.archive_resource_url(resource)),
          class: "flex justify-between px-4 py-2 text-sm text-gray-700",
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
      link_to((@links[0] || helpers.edit_resource_url(id: resource.id)),
        class: "flex justify-between px-4 py-2 text-sm text-gray-700",
        role: "menuitem",
        data: { turbo_action: "advance", turbo_frame: @turbo_frame },
        tabindex: "-1") do
        plain I18n.t(".edit")
        span(class: "sr-only") do
          plain ", "
          plain resource.name rescue ""
        end
      end unless resource_class.to_s == "TimeMaterial" && resource.pushed_to_erp?
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
      link_to(
        helpers.new_modal_url(modal_form: "delete", id: resource.id, resource_class: resource_class.to_s.underscore, modal_next_step: "accept", url: @links[1]),
        data: { turbo_stream: true },
        class: "flex justify-between px-4 py-2 text-sm text-gray-700",
        role: "deleteitem",
        tabindex: "-1") do
        plain I18n.t(".delete")
        span(class: "sr-only") do
          plain ", "
          plain resource.name rescue ""
        end
      end
    end
  end
end
