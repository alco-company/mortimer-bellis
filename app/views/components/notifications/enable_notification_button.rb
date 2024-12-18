class Notifications::EnableNotificationButton < ApplicationComponent
  include Phlex::Rails::Helpers::ImageTag
  #
  def initialize
  end

  def view_template
    form(class: "group m-0", data: { profile_target: "buttonForm" }) do
      button(id: "enable_notifications", class: "flex mort-link-primary group-aria-busy:bg-white", type: "submit",
      data: {
        action: "click->profile#enable",
        profile_target: "enableNotifications"
      }) do
        span(class: "group-aria-busy:hidden block text-sm mr-2") { I18n.t("enable_notifications") }
        render Icons::Link.new css: "mort-link-primary h-6 "
        div(class: "group-aria-busy:block hidden") do
          image_tag "motion-blur.svg", class: "size-6 fill-white"
        end
      end
    end
  end
end
# <!-- notifications bell -->
# <button type="button" class="relative rounded-full bg-white p-1 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-cyan-500 focus:ring-offset-2">
#   <span class="absolute -inset-1.5"></span>
#   <span class="sr-only">View notifications</span>
#   <svg class="size-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true" data-slot="icon">
#     <path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
#   </svg>
# </button>
