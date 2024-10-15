# frozen_string_literal: true

class MobileSidebarComponent < ApplicationComponent
  def view_template
    div(data: { menu_target: "mobileSidebar" }, class: "hidden relative z-50 lg:hidden", role: "dialog", aria_modal: "true") do
      # <!--
      #       Off-canvas menu backdrop, show/hide based on off-canvas menu state.

      #       Entering: "transition-opacity ease-linear duration-300"
      #         From: "opacity-0"
      #         To: "opacity-100"
      #       Leaving: "transition-opacity ease-linear duration-300"
      #         From: "opacity-100"
      #         To: "opacity-0"
      #     -->
      div(class: "fixed inset-0 bg-gray-300/80", aria_hidden: "true")
      div(class: "fixed inset-0 flex") do
        # <!--
        #   Off-canvas menu, show/hide based on off-canvas menu state.

        #   Entering: "transition ease-in-out duration-300 transform"
        #     From: "-translate-x-full"
        #     To: "translate-x-0"
        #   Leaving: "transition ease-in-out duration-300 transform"
        #     From: "translate-x-0"
        #     To: "-translate-x-full"
        # -->
        div(class: "relative mr-16 flex w-full max-w-xs flex-1") do
          # <!--
          #   Close button, show/hide based on off-canvas menu state.

          #   Entering: "ease-in-out duration-300"
          #     From: "opacity-0"
          #     To: "opacity-100"
          #   Leaving: "ease-in-out duration-300"
          #     From: "opacity-100"
          #     To: "opacity-0"
          # -->
          div(class: "absolute left-full top-0 flex w-16 justify-center pt-5") do
            button(type: "button", class: "-m-2.5 p-2.5", data: { action: "click->menu#closeMobileSidebar" }) do
              span(class: "sr-only") { "Close sidebar" }
              render Icons::Cancel.new
            end
          end
          #
          #   "Sidebar component, swap this element with another sidebar if you like"
          #
          render SidebarComponent.new
        end
      end
    end
  end

  private
end
