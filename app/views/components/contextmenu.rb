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
        "flex items-center p-1 text-gray-400 rounded-md hover:text-gray-900 border h-7 -mr-0.5 pl-3",
      id: "options-menu-0-button",
      aria_expanded: "false",
      aria_haspopup: "true"
    ) do
      span(class: "sr-only") { "Open list options" }
      span(class: "text-[10px]") { "More" }
      svg(
        class: "h-5 w-5",
        viewbox: "0 0 20 20",
        fill: "currentColor",
        aria_hidden: "true"
      ) do |s|
        s.path(
          d:
            "M10 3a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM10 8.5a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM11.5 15.5a1.5 1.5 0 10-3 0 1.5 1.5 0 003 0z"
        )
      end
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
      svg(
        class: "h-5 w-5",
        viewbox: "0 0 20 20",
        fill: "currentColor",
        aria_hidden: "true"
      ) do |s|
        s.path(
          d:
            "M10 3a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM10 8.5a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM11.5 15.5a1.5 1.5 0 10-3 0 1.5 1.5 0 003 0z"
        )
      end if @alter
    end
  end

  def list_dropdown
    comment do
      %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
    end
    div(
      data_contextmenu_target: "popup",
      class:
        "hidden absolute right-0 z-10 mt-2 w-32 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-none",
      role: "menu",
      aria_orientation: "vertical",
      aria_labelledby: "options-menu-0-button",
      tabindex: "-1"
    ) do
      whitespace
      comment { %(Active: "bg-gray-50", Not Active: "") }
      whitespace
      link_to helpers.filtering_url(),
        data: { turbo_stream: true, action: "click->contextmenu#hide" },
        class: "block px-3 py-1 text-sm leading-6 text-gray-900",
        role: "menuitem",
        tabindex: "-1" do
        plain I18n.t(".filter")
        span(class: "sr-only") do
          plain ", "
          plain "filter"
        end
      end
      whitespace
      resource_class.any? ?
        link_to(
          helpers.new_modal_url(modal_form: "delete", resource_class: resource_class.to_s.underscore, modal_next_step: "accept"),
          disabled: true,
          data: { turbo_stream: true },
          # link_to helpers.delete_all_url(),
          # data: { turbo_method: :delete, turbo_confirm: "Are you sure?", turbo_stream: true, action: "click->contextmenu#hide" },
          class: "block px-3 py-1 text-sm leading-6 text-gray-900",
          role: "menuitem",
          tabindex: "-1") do
          plain I18n.t(".delete_all")
          span(class: "sr-only") do
            plain ", "
            plain "delete all"
          end
        end :
        div(class: "block px-3 py-1 text-sm leading-6 text-gray-400") { I18n.t(".delete_all") }
      whitespace
      link_to(
        helpers.new_modal_url(modal_form: "import", resource_class: resource_class.to_s.underscore, modal_next_step: "preview"),
        class: "block px-3 py-1 text-sm leading-6 text-gray-900",
        data: { turbo_stream: true }
        ) do
        plain I18n.t(".import")
        span(class: "sr-only") do
          plain ", "
          plain "import"
        end
      end if resource_class.to_s == "User"
      whitespace
      link_to(
        helpers.resources_url() + ".csv",
        class: "block px-3 py-1 text-sm leading-6 text-gray-900",
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
        class: "block px-3 py-1 text-sm leading-6 text-gray-900",
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
      data_contextmenu_target: "popup",
      class:
        "hidden absolute right-0 z-10 mt-2 w-auto min-w-18 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-none",
      role: "menu",
      aria_orientation: "vertical",
      aria_labelledby: "options-menu-0-button",
      tabindex: "-1"
    ) do
      comment { %(Active: "bg-gray-50", Not Active: "") }
      # archive employee
      if resource_class.to_s == "User"
        button_to((helpers.archive_user_url(resource)),
          class: "block px-3 py-1 text-sm leading-6 text-gray-900",
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
        class: "block px-3 py-1 text-sm leading-6 text-gray-900",
        role: "menuitem",
        data: { turbo_action: "advance", turbo_frame: @turbo_frame },
        tabindex: "-1") do
        plain I18n.t(".edit")
        span(class: "sr-only") do
          plain ", "
          plain resource.name rescue ""
        end
      end
      # delete resource
      delete_record
    end
  end

  def delete_record
    if (resource_class.to_s == "User" && resource == Current.user) ||
      resource_class.to_s == "Tenant" && Current.tenant == resource
      span(class: "block px-3 py-1 text-sm leading-6 text-gray-400") do
        plain I18n.t(".delete")
      end
    else
      link_to(
        helpers.new_modal_url(modal_form: "delete", id: resource.id, resource_class: resource_class.to_s.underscore, modal_next_step: "accept", url: @links[1]),
        data: { turbo_stream: true },
        class: "block px-3 py-1 text-sm leading-6 text-gray-900",
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
