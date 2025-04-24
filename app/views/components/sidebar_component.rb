# frozen_string_literal: true

class SidebarComponent < ApplicationComponent
  include Phlex::Rails::Helpers::Request

  def initialize(**attribs, &block)
  end

  def view_template
    comment { "Static sidebar for desktop" }
    div(data: {
      menu_target: "sidebar"
        # transition_enter: "transition ease-in-out duration-300 transform",
        # transition_enter_start: "translate-x-24",
        # transition_enter_end: "translate-x-0",
        # transition_leave: "transition ease-in-out duration-300 transform",
        # transition_leave_start: "translate-x-0",
        # transition_leave_end: "translate-x-24"
      }, class: "hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64 lg:flex-col") do
      # "Sidebar component, swap this element with another sidebar if you like"
      div(class: "flex h-16 shrink-0 items-center") do
        render LogoComponent.new
        button(class: "hidden lg:grid grow w-full justify-items-end", data: { menu_target: "tsb", action: "click->menu#toggleSidebar" }) {
          render Icons::ChevronLeft.new cls: "h-6 w-6 text-gray-400 collapse-sidebar", id: "collapseSidebar"
        }
      end
      render NavigationComponent.new
    end
  end

  # def old_view_template
  #   div(class: "flex grow flex-col gap-y-5 overflow-y-auto border-r border-gray-200 bg-white px-6") do
  #     div(class: "flex h-16 shrink-0 items-center") do
  #       render LogoComponent.new
  #       button(class: "hidden lg:grid grow w-full justify-items-end", data: { menu_target: "tsb", action: "click->menu#toggleSidebar" }) {
  #         render Icons::ChevronLeft.new cls: "h-6 w-6 text-gray-400 collapse-sidebar", id: "collapseSidebar"
  #       }
  #     end
  #     render NavigationComponent.new
  #   end
  # end
end
