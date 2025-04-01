class NotificationOutlet < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::ImageTag

  def initialize(enable: "hidden", disabled: "hidden")
    @enable = enable
    @disabled = disabled
  end

  def view_template
    turbo_frame_tag("notifications_outlet") do
      button(
        id: "enable_notifications",
        class: %(#{@enable} mort-btn-primary group-aria-busy:bg-white),
        data_turbo: "false",
        data_profile_target: "enableNotifications",
        data_action: " click->profile#enable"
      ) do
        span(class: "group-aria-busy:hidden block") do
          plain I18n.t("enable_notifications")
        end
        div(class: "group-aria-busy:block hidden") do
          image_tag "motion-blur.svg", class: "size-6 fill-white"
        end
      end
      button(
        id: "disable_notifications",
        class: %(#{@disabled} mort-btn-warning),
        data_turbo: "false",
        data_transition_enter: "transition ease-in duration-700",
        data_transition_enter_start: "transform opacity-0",
        data_transition_enter_end: "transform opacity-100",
        data_transition_leave: "transition ease-out duration-700",
        data_transition_leave_start: "transform opacity-100",
        data_transition_leave_end: "transform opacity-0",
        data_profile_target: "disableNotifications",
        data_action: " click->profile#disable"
      ) do
        plain I18n.t("disable_notifications")
      end
    end
  end
end
