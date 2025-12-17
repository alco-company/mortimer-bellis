# frozen_string_literal: true

class TopbarComponent < ApplicationComponent
  attr_accessor :gradient, :params

  def initialize(params: {})
    @params = params
    @gradient = Rails.env.production? ? "from-cyan-200 to-sky-600" : "from-pink-200 to-pink-600"
  end
  #
  # top navigation with menu button, search, notifications, and profile
  def view_template
    # topbar for mobile & desktop
    div(data: { controller: "navigation" }, class: "sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-4 bg-gradient-to-r #{gradient} bg-white px-4 shadow-xs sm:gap-x-6 sm:px-6 lg:px-8") do
      mobile_menu_button if Current.user
    # separator
    # div(class: "h-6 w-px bg-gray-900/10 lg:hidden", aria_hidden: "true") { }

    # Search bar - route to current index so query param gets applied
    div(class: "flex flex-1 gap-x-4 self-stretch lg:gap-x-6") do
        # div(class: "flex flex-1 justify-between px-4 sm:px-6 lg:mx-auto lg:max-w-6xl lg:px-8") do
        # div(data: { controller: "live-search", "live-search-url-value": url_for(controller: params_ctrl, action: :index) }) do
        render SearchComponent.new params: params
        # end

        div(class: "flex items-center gap-x-4 lg:gap-x-6") do
          # div(class: "ml-4 flex items-center md:ml-6")
          # reload_button
          # render Notifications::NotificationBell.new recipient: Current.user

          # separator
          div(class: "hidden lg:block lg:h-6 lg:w-px lg:bg-gray-900/10")

          render ProfileDropmenuComponent.new
        end
      end if Current.user
    end
  end

  #
  # top navigation with menu button, search, notifications, and profile
  def old_view_template
    # topbar for mobile & desktop
    div(data: { controller: "navigation" }, class: "sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-4 bg-gradient-to-r from-cyan-200 to-sky-600 bg-white px-4 shadow-xs sm:gap-x-6 sm:px-6 lg:px-8") do
      mobile_menu_button
      # separator
      div(class: "h-6 w-px bg-gray-900/10 lg:hidden", aria_hidden: "true") { }

      # Search bar & notifications-bell & profile
      div(class: "flex flex-1 gap-x-4 self-stretch lg:gap-x-6") do
        render SearchComponent.new

        div(class: "flex items-center gap-x-4 lg:gap-x-6") do
          render Notifications::NotificationBell.new recipient: Current.user

          # separator
          div(class: "hidden lg:block lg:h-6 lg:w-px lg:bg-gray-900/10")

          render ProfileDropmenuComponent.new
        end
      end if Current.user
    end
  end

  private

    def old_mobile_menu_button
      button(type: "button", class: "-m-2.5 p-2.5 text-gray-700 lg:hidden", data: { action: "mobilesidebar#show" }) do
        span(class: "sr-only") { "Open sidebar" }
        render Icons::Hamburger.new css: "h-6 w-6 text-sky-900 hover:text-sky-400"
      end
    end

    def mobile_menu_button
      button(type: "button", class: "border-r border-gray-200 px-4 text-gray-400 focus:outline-hidden focus:ring-2 focus:ring-inset focus:ring-cyan-500 lg:hidden", data: { action: "mobilesidebar#toggleSidebar" }) do
        span(class: "sr-only") { "Open sidebar" }
        render Icons::Hamburger2.new css: "h-6 w-6 text-sky-900 hover:text-sky-400 hover:rotate-90"
      end
    end

    def reload_button
      button(type: "button", class: "text-sky-200 focus:outline-hidden focus:ring-2 focus:ring-inset focus:ring-cyan-500 md:hidden", data: { action: "mobilesidebar#reload" }) do
        span(class: "sr-only") { "Open sidebar" }
        render Icons::Reload.new css: "h-6 w-6 text-sky-200 hover:text-sky-400 hover:rotate-90"
      end
    end
end
