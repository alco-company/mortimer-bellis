# frozen_string_literal: true

class TopbarComponent < ApplicationComponent
  #
  # top navigation with menu button, search, notifications, and profile
  def view_template
    div(data: { controller: "navigation" }, class: "sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-4 bg-gradient-to-r from-cyan-200 to-sky-600 bg-white px-4 shadow-sm sm:gap-x-6 sm:px-6 lg:px-8") do
      mobile_menu_button
      # separator
      div(class: "h-6 w-px bg-gray-900/10 lg:hidden", aria_hidden: "true") { }

      div(class: "flex flex-1 gap-x-4 self-stretch lg:gap-x-6") do
        render SearchComponent.new

        div(class: "flex items-center gap-x-4 lg:gap-x-6") do
          render ViewNotificationsComponent.new

          # separator
          div(class: "hidden lg:block lg:h-6 lg:w-px lg:bg-gray-900/10")
          render ProfileDropmenuComponent.new
        end
      end
    end
  end

  private
    def mobile_menu_button
      button(type: "button", class: "-m-2.5 p-2.5 text-gray-700 lg:hidden", data: { action: "click->menu#openMobileSidebar" }) do
        span(class: "sr-only") { "Open sidebar" }
        render Icons::Hamburger.new
      end
    end
end
