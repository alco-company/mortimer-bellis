# frozen_string_literal: true

class TopbarComponent < ApplicationComponent
  def view_template
    div(data: { controller: "navigation" }, class: "sticky top-0 z-40 lg:mx-auto w-full bg-gradient-to-r from-cyan-200 to-sky-600") do
      div(
        class:
          "flex h-16 items-center gap-x-4 border-b border-gray-200 px-4 shadow-sm sm:gap-x-6 sm:px-6 lg:shadow-none"
      ) do
        whitespace
        button(type: "button", class: "-m-2.5 p-2.5 text-gray-700 lg:hidden", data: { action: "click->menu#openMobileSidebar" }) do
          whitespace
          span(class: "sr-only") { "Open sidebar" }
          whitespace
          svg(
            class: "h-6 w-6",
            fill: "none",
            viewbox: "0 0 24 24",
            stroke_width: "1.5",
            stroke: "currentColor",
            aria_hidden: "true"
          ) do |s|
            s.path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              d: "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
            )
          end
          whitespace
        end
        whitespace
        comment { "Separator" }
        div(class: "h-6 w-px bg-gray-200 lg:hidden", aria_hidden: "true")
        div(class: "flex flex-1 gap-x-4 self-stretch lg:gap-x-6") do
          form(class: "relative flex flex-1", action: "#", method: "GET") do
            whitespace
            comment do
              %(<label for="search-field" class="sr-only">Search</label> <svg class="pointer-events-none absolute inset-y-0 left-0 h-full w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"> <path fill-rule="evenodd" d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z" clip-rule="evenodd"/> </svg> <input id="search-field" class="block h-full w-full border-0 py-0 pl-8 pr-0 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm" placeholder="Search..." type="search" name="search">)
            end
          end
          div(class: "flex items-center gap-x-4 lg:gap-x-6") do
            render ViewNotificationsComponent.new
            # "Separator"
            div(
              class: "hidden lg:block lg:h-6 lg:w-px lg:bg-gray-200",
              aria_hidden: "true"
            )
            render ProfileDropmenuComponent.new
          end
        end
      end
    end
  end

  private
end
