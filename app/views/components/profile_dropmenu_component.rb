# frozen_string_literal: true

class ProfileDropmenuComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo
  def view_template
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
        # link_to( "Settings", "#", class: "block px-4 py-2 text-sm text-gray-700", role: "menuitem", tabindex: "-1", id: "user-menu-item-1")
        link_to("Sign out", destroy_user_session_path(), class: "block px-4 py-2 text-sm text-gray-700", method: :delete, data: { turbo_method: :delete }, role: "menuitem", tabindex: "-1", id: "user-menu-item-2")
      end
    end
  end
end
