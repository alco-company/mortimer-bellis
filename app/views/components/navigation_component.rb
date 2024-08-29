# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag

  attr_accessor :items

  def initialize(items: [], root: nil, locale: nil, time_zone: nil)
    @items = items
    @root = root
    @locale = locale
    @time_zone = time_zone
  end

  def view_template
    nav(class: "w-full fixed top-0 z-40 bg-gradient-to-r from-cyan-200 to-sky-600", data: { controller: "navigation" }) do
      div(class: "mx-auto  px-2 sm:px-6 lg:px-8") do
        div(class: "relative flex h-16 items-center justify-between") do
          div(class: "absolute inset-y-0 left-0 flex items-center lg:hidden") do
            mobile_menu_button
          end
          div(
            class:
              "flex flex-1 items-center justify-center sm:items-stretch sm:justify-start"
          ) do
            div(class: "flex flex-shrink-0 items-center hidden lg:block") do
              if Current.account && Current.account.logo.attached?
                helpers.render_logo logo: Current.account.logo, root: @root
              else
                helpers.render_logo root: @root
              end
            end
            div(class: "sm:ml-6 hidden lg:block") do
              desktop_menu
            end
          end
          div(class: " absolute inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0") do
            view_notifications
            profile_dropdown if Current.user.present?
          end
        end
      end
      mobile_menu
    end
  end

  def mobile_menu_button
    comment { "Mobile menu button" }
    button(
      type: "button",
      data: { action: "click->navigation#toggleMenu" },
      class:
        "relative inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-sky-700 hover:text-white focus:outline-none focus:ring-2 focus:ring-inset focus:ring-cyan-300",
      aria_controls: "mobile-menu",
      aria_expanded: "false"
    ) do
      span(class: "absolute -inset-0.5")
      span(class: "sr-only") { "Open main menu" }
      comment do
        %(Icon when menu is closed. Menu open: "hidden", Menu closed: "block")
      end
      svg(
        class: "block h-6 w-6",
        data: { navigation_target: "menuClose" },
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
      comment do
        %(Icon when menu is open. Menu open: "block", Menu closed: "hidden")
      end
      svg(
        class: "hidden h-6 w-6",
        data: { navigation_target: "menuOpen" },
        fill: "none",
        viewbox: "0 0 24 24",
        stroke_width: "1.5",
        stroke: "currentColor",
        aria_hidden: "true"
      ) do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          d: "M6 18L18 6M6 6l12 12"
        )
      end
    end
  end

  def desktop_menu
    div(class: "flex space-x-4 py-4") do
      comment do
        %(Current: "bg-gray-900 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white")
      end
      # a(
      #   href: helpers.root_path,
      #   class:
      #     "mort-nav-link",    # bg-gray-900 text-white rounded-md px-3 py-2 text-sm font-medium
      #   aria_current: "page"
      # ) { I18n.t "menu.home" }
      items.each do |item|
        a(
          href: item[:url],
          class:
            "mort-nav-link", # bg-gray-900 text-white block rounded-md px-3 py-2 text-sm font-medium
          aria_current: "page"
        ) { item[:title] }
      end
    end
  end

  def mobile_menu
    comment { "Mobile menu, show/hide based on menu state." }
    div(data: { navigation_target: "mobileMenu" }, class: "hidden lg:hidden", id: "mobile-menu") do
      div(class: "space-y-1 px-2 pb-3 pt-2") do
        a(
          href: @root || helpers.root_path,
          class:
            "mort-nav-link",
          aria_current: "page"
        ) { "Hjem" }
        items.each do |item|
          a(
            href: item[:url],
            class:
              "mort-nav-link",
            aria_current: "page"
          ) { item[:title] }
        end
      end
    end
  end

  def view_notifications
    comment { "View notifications" }
    link_to notifications_path, class: "relative rounded-full bg-transparent p-1 text-blue-300 hover:text-white focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800" do
      span(class: "absolute -inset-1.5")
      span(class: "sr-only") { "View notifications" }
      render NotificationBell.new(recipient: Current.user)
    end
  end

  def profile_dropdown
    comment { "Profile dropdown" }
    div(class: " relative ml-3") do
      div do
        button(
          type: "button",
          data: {
            navigation_target: "profileMenuButton",
            action: "touchstart->navigation#tapDrop click->navigation#tapDrop click@window->navigation#hideDrop"
          },
          class:
            "relative flex rounded-full bg-sky-200 text-sm focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800",
          id: "user-menu-button",
          aria_expanded: "false",
          aria_haspopup: "true"
        ) do
          span(class: "absolute -inset-1.5")
          span(class: "sr-only") { "Open user menu" }
          if Current.user
            if Current.user.mugshot.attached?
              image_tag(Current.user.mugshot, class: "h-8 w-8 rounded-full")
            else
              image_tag("icons8-customer-64.png", class: "h-8 w-8 rounded-full")
            end
          end
          # helpers.user_mugshot(Current.user.mugshot, css: "h-8 w-8 rounded-full")
          # img(
          #   class: "h-8 w-8 rounded-full",
          #   src:
          #     "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80",
          #   alt: ""
          # )
        end
      end
      comment do
        %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
      end
      div(
        class:
          "hidden absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none",
        role: "menu",
        data: { navigation_target: "profileMenu" },
        aria_orientation: "vertical",
        aria_labelledby: "user-menu-button",
        tabindex: "-1"
      ) do
        comment { %(Active: "bg-gray-100", Not Active: "") }
        p(class: "text-sm font-medium px-4 py-2") { Current.user.name }
        hr
        link_to("Your Profile", edit_user_registration_path, class: "block px-4 py-2 text-sm text-gray-700", role: "menuitem", tabindex: "-1", id: "user-menu-item-0")
        link_to("Invite New User", new_user_invitation_path, class: "block px-4 py-2 text-sm text-gray-700", role: "menuitem", tabindex: "-1", id: "user-menu-item-0") unless Current.user.user?
        # link_to( "Settings", "#", class: "block px-4 py-2 text-sm text-gray-700", role: "menuitem", tabindex: "-1", id: "user-menu-item-1")
        link_to("Sign out", destroy_user_session_path(), class: "block px-4 py-2 text-sm text-gray-700", method: :delete, data: { turbo_method: :delete }, role: "menuitem", tabindex: "-1", id: "user-menu-item-2")
      end
    end
  end
end
