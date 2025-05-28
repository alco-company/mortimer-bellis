# frozen_string_literal: true

class ProfileDropmenuComponent < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo

  def view_template
    comment { "Profile dropdown" }
    turbo_frame_tag "profile_dropmenu" do
      profile_dropmenu
    end
  end

  def profile_dropmenu
    div(class: "relative", data: { controller: "contextmenu" }) do
      button(
        type: "button",
         data: {
            navigation_target: "profileMenuButton",
            contextmenu_target: "button",
            action: "touchstart->contextmenu#tap:passive click@window->contextmenu#hide click->contextmenu#tap"
          },
         class: "-m-1.5 flex items-center p-1.5 cursor-pointer",
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
          "hidden absolute right-0 z-10 mt-2.5 w-44 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-hidden",
        role: "menu",
        data: {
          navigation_target: "profileMenu",
          contextmenu_target: "popup",
          transition_enter: "transition ease-out duration-300",
          transition_enter_start: "transform opacity-0 scale-95",
          transition_enter_end: "transform opacity-100 scale-100",
          transition_leave: "transition ease-in duration-75",
          transition_leave_start: "transform opacity-100 scale-100",
          transition_leave_end: "transform opacity-0 scale-95"
        },
        aria_orientation: "vertical",
        aria_labelledby: "user-menu-button",
        tabindex: "-1"
      ) do
        comment { %(Active: "bg-gray-50", Not Active: "") }
        p(class: "text-sm font-medium px-4 py-2") { Current.user&.name }
        hr
        link_to(
          I18n.t("topbar.profile.your_profile"),
          edit_users_registrations_url,
          class: "block px-3 py-1 text-sm leading-6 text-gray-900",
          data: { turbo_action: "advance", turbo_frame: "form" },
          role: "menuitem",
          tabindex: "-1",
          id: "user-menu-item-0")
        link_to(
          I18n.t("topbar.profile.change_password"),
          edit_users_password_url(-1),
          class: "block px-3 py-1 text-sm leading-6 text-gray-900",
          # data: { turbo_action: "advance", turbo_frame: "form"  },
          target: "_top",
          role: "menuitem",
          tabindex: "-1",
          id: "user-menu-item-1")
          hr
        # link_to( "Settings", "#", class: "block px-3 py-1 text-sm leading-6 text-gray-900", role: "menuitem", tabindex: "-1", id: "user-menu-item-1")
        link_to(I18n.t("topbar.profile.sign_out"), users_session_path(), class: "block px-3 py-1 text-sm leading-6 text-gray-900", method: :delete, data: { turbo_method: :delete }, role: "menuitem", tabindex: "-1", id: "user-menu-item-2")
      end
    end
  end
end



# <!-- Profile dropdown -->
# <div class="relative ml-3">
#   <div>
#     <button type="button" class="relative flex max-w-xs items-center rounded-full bg-white text-sm focus:outline-hidden focus:ring-2 focus:ring-cyan-500 focus:ring-offset-2 lg:rounded-md lg:p-2 lg:hover:bg-gray-50" id="user-menu-button" aria-expanded="false" aria-haspopup="true">
#       <span class="absolute -inset-1.5 lg:hidden"></span>
#       <img class="size-8 rounded-full" src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80" alt="">
#       <span class="ml-3 hidden text-sm font-medium text-gray-700 lg:block"><span class="sr-only">Open user menu for </span>Emilia Birch</span>
#       <svg class="ml-1 hidden size-5 shrink-0 text-gray-400 lg:block" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
#         <path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 0 1 1.06 0L10 11.94l3.72-3.72a.75.75 0 1 1 1.06 1.06l-4.25 4.25a.75.75 0 0 1-1.06 0L5.22 9.28a.75.75 0 0 1 0-1.06Z" clip-rule="evenodd" />
#       </svg>
#     </button>
#   </div>

#   <!--
#     Dropdown menu, show/hide based on menu state.

#     Entering: "transition ease-out duration-100"
#       From: "transform opacity-0 scale-95"
#       To: "transform opacity-100 scale-100"
#     Leaving: "transition ease-in duration-75"
#       From: "transform opacity-100 scale-100"
#       To: "transform opacity-0 scale-95"
#   -->
#   <div class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-slate-100 focus:outline-hidden" role="menu" aria-orientation="vertical" aria-labelledby="user-menu-button" tabindex="-1">
#     <!-- Active: "bg-gray-100 outline-hidden", Not Active: "" -->
#     <a href="#" class="block px-4 py-2 text-sm text-gray-700" role="menuitem" tabindex="-1" id="user-menu-item-0">Your Profile</a>
#     <a href="#" class="block px-4 py-2 text-sm text-gray-700" role="menuitem" tabindex="-1" id="user-menu-item-1">Settings</a>
#     <a href="#" class="block px-4 py-2 text-sm text-gray-700" role="menuitem" tabindex="-1" id="user-menu-item-2">Logout</a>
#   </div>
# </div>
