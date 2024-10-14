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
          # search
          render SearchComponent.new
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
