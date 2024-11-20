class WorkScheduleTemplate < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :template

  def initialize(template:, &block)
    @template = template
  end

  def view_template(&block)
    li(class: "flex items-center justify-between gap-x-6 py-5") do
      div(class: "min-w-0") do
        div(class: "flex items-start gap-x-3") do
          p(class: "text-sm font-semibold leading-6 text-gray-900") do
            plain template
          end
          p(
            class:
              "mt-0.5 whitespace-nowrap rounded-md bg-green-50 px-1.5 py-0.5 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20"
          ) { "Complete" }
        end
        div(
          class:
            "mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500"
        ) do
          p(class: "whitespace-nowrap") do
            plain "Due on "
            time(datetime: "2023-03-17T00:00Z") { "March 17, 2023" }
          end
          svg(viewbox: "0 0 2 2", class: "h-0.5 w-0.5 fill-current") do |s|
            s.circle(cx: "1", cy: "1", r: "1")
          end
          p(class: "truncate") { "Created by Leslie Alexander" }
        end
      end
      div(class: "flex flex-none items-center gap-x-4") do
        a(
          href: "#",
          class:
            "hidden rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:block"
        ) do
          plain "View project"
          span(class: "sr-only") { ", GraphQL API" }
        end
        div(class: "relative flex-none") do
          button(
            type: "button",
            class: "-m-2.5 block p-2.5 text-gray-500 hover:text-gray-900",
            id: "options-menu-0-button",
            aria_expanded: "false",
            aria_haspopup: "true"
          ) do
            span(class: "sr-only") { "Open options" }
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
          comment do
            %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
          end
          div(
            class:
              "absolute hidden right-0 z-10 mt-2 w-32 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-none",
            role: "menu",
            aria_orientation: "vertical",
            aria_labelledby: "options-menu-0-button",
            tabindex: "-1"
          ) do
            comment { %(Active: "bg-gray-50", Not Active: "") }
            a(
              href: "#",
              class: "block px-3 py-1 text-sm leading-6 text-gray-900",
              role: "menuitem",
              tabindex: "-1",
              id: "options-menu-0-item-0"
            ) do
              plain "Edit"
              span(class: "sr-only") { ", GraphQL API" }
            end
            a(
              href: "#",
              class: "block px-3 py-1 text-sm leading-6 text-gray-900",
              role: "menuitem",
              tabindex: "-1",
              id: "options-menu-0-item-1"
            ) do
              plain "Move"
              span(class: "sr-only") { ", GraphQL API" }
            end
            a(
              href: "#",
              class: "block px-3 py-1 text-sm leading-6 text-gray-900",
              role: "menuitem",
              tabindex: "-1",
              id: "options-menu-0-item-2"
            ) do
              plain "Delete"
              span(class: "sr-only") { ", GraphQL API" }
            end
          end
        end
      end
    end
  end
end
