class Contextmenu < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  include Rails.application.routes.url_helpers

  attr_accessor :resource, :resource_class, :list

  def initialize(resource: nil, list: nil, resource_class: nil, turbo_frame: "_top", alter: true, links: [])
    @resource = resource
    @resource_class = resource_class
    @list = list
    @turbo_frame = turbo_frame
    @alter = alter
    @links = links
  end

  def view_template
    div(data_controller: "contextmenu", class: "relative flex-none") do
      whitespace
      button(
        type: "button",
        data_contextmenu_target: "button",
        data_action: "touchstart->contextmenu#tap click->contextmenu#tap click@window->contextmenu#hide",
        class: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
        id: "options-menu-0-button",
        aria_expanded: "false",
        aria_haspopup: "true"
      ) do
        whitespace
        span(class: "sr-only") { "Open options" }
        whitespace
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
        whitespace
      end
      whitespace
      case true
      when !resource.nil?; dropdown
      when !list.nil?; list_dropdown
      end
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
        plain "Filter"
        span(class: "sr-only") do
          plain ", "
          plain "filter"
        end
      end
      whitespace
      link_to(
        helpers.modal_new_url(modal_form: "import", resource_class: resource_class.to_s.underscore, modal_next_step: "preview"), 
        class: "block px-3 py-1 text-sm leading-6 text-gray-900", 
        data: { turbo_stream: true }
        ) do 
        plain "Importér"
        span(class: "sr-only") do
          plain ", "
          plain "import"
        end
      end
      whitespace
      link_to(
        helpers.resources_url() + ".csv",
        class: "block px-3 py-1 text-sm leading-6 text-gray-900",
        role: "menuitem",
        tabindex: "-1",
        data: { turbo_frame: @turbo_frame }) do
        plain "Eksportér"
        span(class: "sr-only") do
          plain ", "
          plain "export"
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
      whitespace
      comment { %(Active: "bg-gray-50", Not Active: "") }
      whitespace
      link_to((@links[0] || helpers.edit_resource_url(id: resource.id)),
        class: "block px-3 py-1 text-sm leading-6 text-gray-900",
        role: "menuitem",
        data: { turbo_action: "advance", turbo_frame: @turbo_frame },
        tabindex: "-1") do
        plain "Ret"
        span(class: "sr-only") do
          plain ", "
          plain resource.name rescue ""
        end
      end
      whitespace
      link_to((@links[1] || resource),
        class: "block px-3 py-1 text-sm leading-6 text-gray-900",
        role: "menuitem",
        tabindex: "-1",
        data: { turbo_method: :delete, turbo_confirm: "Ar you sure?" }) do
        plain "Slet"
        span(class: "sr-only") do
          plain ", "
          plain resource.name rescue ""
        end
      end
    end
  end
end
