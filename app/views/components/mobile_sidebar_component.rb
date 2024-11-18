# frozen_string_literal: true

class MobileSidebarComponent < ApplicationComponent
  def view_template
    # Off-canvas menu for mobile, show/hide based on off-canvas menu state.
    div(data: { mobilesidebar_target: "container" }, class: "hidden relative z-40 lg:hidden", role: "dialog", aria_modal: "true") do
      # Off-canvas menu backdrop, show/hide based on off-canvas menu state
      div(class: "fixed inset-0 bg-sky-600/25",
        data: {
          mobilesidebar_target: "backdrop",
          transition_enter: "ease-in-out duration-500",
          transition_enter_start: "opacity-0",
          transition_enter_end: "opacity-100",
          transition_leave: "ease-in-out duration-500",
          transition_leave_start: "opacity-100",
          transition_leave_end: "opacity-0"
        },
        aria_hidden: "true")
      div(class: "fixed inset-0 z-40 flex") do
        # Off-canvas menu, show/hide based on off-canvas menu state.
        div(class: "relative flex w-full max-w-xs flex-1 flex-col bg-white top-16 pb-4 pt-5",
          data: {
            mobilesidebar_target: "panel",
            transition_enter: "transition ease-in-out duration-300 transform",
            transition_enter_start: "-translate-x-full",
            transition_enter_end: "translate-x-0",
            transition_leave: "transition ease-in-out duration-300 transform",
            transition_leave_start: "translate-x-0",
            transition_leave_end: "-translate-x-full"
          },
        ) do
          # Close button, show/hide based on off-canvas menu state.
          div(class: "absolute right-0 top-0 -mr-12 pt-2",
            data: {
              mobilesidebar_target: "closeButton",
              transition_enter: "ease-in-out duration-500",
              transition_enter_start: "opacity-0",
              transition_enter_end: "opacity-100",
              transition_leave: "ease-in-out duration-500",
              transition_leave_start: "opacity-100",
              transition_leave_end: "opacity-0"
            }
            ) do
            button(
              type: "button",
              data: { action: "click->mobilesidebar#hide" },
              class: "relative ml-1 flex size-10 items-center justify-center rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
            ) do
              span(class: "absolute -inset-0.5")
              span(class: "sr-only") { "Close sidebar" }
              render Icons::Cancel.new
            end
          end
          render NavigationComponent.new
        end
        div(class: "w-14 shrink-0", aria_hidden: "true") do
          comment do
            "Dummy element to force sidebar to shrink to fit close icon"
          end
        end
      end
    end
  end
end
