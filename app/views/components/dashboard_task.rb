class DashboardTask < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :task, :show_options

  def initialize(task:, show_options: false)
    @task = task
    @show_options = show_options
  end

  def view_template
    url, help = task.link.split(/,| |;/)
    help ||= "https://mortimer.pro/help"
    li(class: "overflow-hidden rounded-xl border border-gray-200", data: { controller: "hidden-description" }) do
      div(
        class:
          "flex justify-between items-center gap-x-4 border-b border-gray-900/5 bg-gray-50 p-2"
      ) do
        if url.include? "/"
          div(class: "flex text-sm/6 text-gray-900") do
            link_to task.title, url, class: "mort-link-primary mr-2 text-sm"
            render Icons::Link.new css: "mort-link-primary h-6 "
            context_menu if show_options
          end
          render Icons::ChevronUp.new css: "mort-link-primary h-6 rotate-180 cursor-pointer", data: { action: "click->hidden-description#toggle" }
        else
          helpers.send(url)
        end
      end
      dl(class: "-my-3  px-2 py-4 text-sm/6") do
        div(class: "hidden flex justify-between gap-x-4 py-3 text-xs", data: { hidden_description_target: "description" }) { task.description } unless task.description.blank?
        p { link_to I18n.t("tasks.dashboard.get_help_here"), help, class: "mort-link-error text-xs" }
        # dt(class: "text-gray-500") { "Last invoice" }
        # dd(class: "text-gray-700") do
        #   time(datetime: "2022-12-13") { "December 13, 2022" }
        # end
        # end
        # div(class: "flex justify-between  self-end gap-x-4 py-3") { link_to I18n.t(".start"), task.link, class: "mort-btn-primary" }
        #   dt(class: "text-gray-500") { "Amount" }
        #   dd(class: "flex items-start gap-x-2") do
        #     div(class: "font-medium text-gray-900") { "$2,000.00" }
        #     div(
        #       class:
        #         "rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
        #     ) { "Overdue" }
        #   end
        # end
      end
    end
  end

  def context_menu
    div(class: "relative ml-auto") do
      button(
        type: "button",
        class: "-m-2.5 block p-2.5 text-gray-400 hover:text-gray-500",
        id: "options-menu-0-button",
        aria_expanded: "false",
        aria_haspopup: "true"
      ) do
        span(class: "sr-only") { "Open options" }
        svg(
          class: "size-5",
          viewbox: "0 0 20 20",
          fill: "currentColor",
          aria_hidden: "true",
          data_slot: "icon"
        ) do |s|
          s.path(
            d:
              "M3 10a1.5 1.5 0 1 1 3 0 1.5 1.5 0 0 1-3 0ZM8.5 10a1.5 1.5 0 1 1 3 0 1.5 1.5 0 0 1-3 0ZM15.5 8.5a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3Z"
          )
        end
      end
      comment do
        %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
      end
      div(
        class:
          "absolute right-0 z-10 mt-0.5 w-32 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-none",
        role: "menu",
        aria_orientation: "vertical",
        aria_labelledby: "options-menu-0-button",
        tabindex: "-1"
      ) do
        comment { %(Active: "bg-gray-50 outline-none", Not Active: "") }
        a(
          href: "#",
          class: "block px-3 py-1 text-sm/6 text-gray-900",
          role: "menuitem",
          tabindex: "-1",
          id: "options-menu-0-item-0"
        ) do
          plain "View"
          span(class: "sr-only") { ", Tuple" }
        end
        a(
          href: "#",
          class: "block px-3 py-1 text-sm/6 text-gray-900",
          role: "menuitem",
          tabindex: "-1",
          id: "options-menu-0-item-1"
        ) do
          plain "Edit"
          span(class: "sr-only") { ", Tuple" }
        end
      end
    end
  end
end
