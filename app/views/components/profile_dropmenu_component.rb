# frozen_string_literal: true

class ProfileDropmenuComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo

  def view_template
    comment { "Profile dropdown" }
    div(class: "relative") do
      button(
        type: "button",
         data: {
            navigation_target: "profileMenuButton",
            action: "touchstart->navigation#tapDrop click->navigation#tapDrop click@window->navigation#hideDrop"
          },
         class: "-m-1.5 flex items-center p-1.5",
        id: "user-menu-button",
        aria_expanded: "false",
        aria_haspopup: "true"
      ) do
        span(class: "sr-only") { "Open user menu" }
        if Current.user
          if Current.user&.mugshot&.attached?
            image_tag(Current.user&.mugshot, class: "h-8 w-8 rounded-full")
          else
            image_tag("icons8-customer-64.png", class: "h-8 w-8 rounded-full bg-white")
          end
        end
        span(class: "hidden lg:flex lg:items-center") do
          span(
            class: "ml-4 text-sm font-semibold leading-6 text-sky-300",
            aria_hidden: "true"
          ) { Current.user&.name }
          svg(
            class: "ml-2 h-5 w-5 text-sky-200",
            viewbox: "0 0 20 20",
            fill: "currentColor",
            aria_hidden: "true",
            data_slot: "icon"
          ) do |s|
            s.path(
              fill_rule: "evenodd",
              d:
                "M5.22 8.22a.75.75 0 0 1 1.06 0L10 11.94l3.72-3.72a.75.75 0 1 1 1.06 1.06l-4.25 4.25a.75.75 0 0 1-1.06 0L5.22 9.28a.75.75 0 0 1 0-1.06Z",
              clip_rule: "evenodd"
            )
          end
        end
      end
      comment do
        %(Dropdown menu, show/hide based on menu state. Entering: "transition ease-out duration-100" From: "transform opacity-0 scale-95" To: "transform opacity-100 scale-100" Leaving: "transition ease-in duration-75" From: "transform opacity-100 scale-100" To: "transform opacity-0 scale-95")
      end
      div(
        class:
          "hidden absolute right-0 z-10 mt-2.5 w-44 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-none",
        role: "menu",
        data: { navigation_target: "profileMenu" },
        aria_orientation: "vertical",
        aria_labelledby: "user-menu-button",
        tabindex: "-1"
      ) do
        comment { %(Active: "bg-gray-50", Not Active: "") }
        p(class: "text-sm font-medium px-4 py-2") { Current.user&.name }
        hr
        link_to("Your Profile", edit_user_registration_path, class: "block px-3 py-1 text-sm leading-6 text-gray-900", role: "menuitem", tabindex: "-1", id: "user-menu-item-0")
        # link_to( "Settings", "#", class: "block px-3 py-1 text-sm leading-6 text-gray-900", role: "menuitem", tabindex: "-1", id: "user-menu-item-1")
        link_to("Sign out", destroy_user_session_path(), class: "block px-3 py-1 text-sm leading-6 text-gray-900", method: :delete, data: { turbo_method: :delete }, role: "menuitem", tabindex: "-1", id: "user-menu-item-2")
      end
    end
  end
end
