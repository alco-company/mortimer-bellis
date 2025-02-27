class HeaderProfile < Phlex::HTML
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo

  def view_template
    comment { "Page header" }
    div(class: "bg-white sm:shadow sm:mx-2 sm:border-t sm:border-gray-50", data: { controller: "profile" }) do
      div(class: "px-4 sm:px-6 lg:mx-auto lg:max-w-6xl lg:px-8") do
        div(
          class:
            "py-6 md:flex md:items-center md:justify-between"
        ) do
          div(class: "min-w-0 flex-1") do
            comment { "Profile" }
            div(class: "flex items-center") do
              if Current.user
                if Current.user.mugshot.attached?
                  image_tag(Current.user.mugshot, class: "hidden h-16 w-16 rounded-full sm:block")
                else
                  image_tag("icons8-customer-64.png", class: "hidden h-16 w-16 rounded-full sm:block")
                end
              end
              div do
                div(class: "flex items-center") do
                  if Current.user
                    if Current.user.mugshot.attached?
                      image_tag(Current.user.mugshot, class: " h-16 w-16 rounded-full sm:hidden")
                    else
                      image_tag("icons8-customer-64.png", class: " h-16 w-16 rounded-full sm:hidden")
                    end
                  end
                  h1(
                    class:
                      "ml-3 text-2xl font-bold leading-7 text-gray-900 sm:truncate sm:leading-9"
                  ) { salutation }
                end
                dl(
                  class:
                    "mt-6 flex flex-col sm:ml-3 sm:mt-1 sm:flex-row sm:flex-wrap"
                ) do
                  dt(class: "sr-only") { "Company" }
                  dd(
                    class:
                      "flex items-center text-sm font-medium capitalize text-gray-500 sm:mr-6"
                  ) do
                    svg(
                      class: "mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400",
                      viewbox: "0 0 20 20",
                      fill: "currentColor",
                      aria_hidden: "true"
                    ) do |s|
                      s.path(
                        fill_rule: "evenodd",
                        d:
                          "M4 16.5v-13h-.25a.75.75 0 010-1.5h12.5a.75.75 0 010 1.5H16v13h.25a.75.75 0 010 1.5h-3.5a.75.75 0 01-.75-.75v-2.5a.75.75 0 00-.75-.75h-2.5a.75.75 0 00-.75.75v2.5a.75.75 0 01-.75.75h-3.5a.75.75 0 010-1.5H4zm3-11a.5.5 0 01.5-.5h1a.5.5 0 01.5.5v1a.5.5 0 01-.5.5h-1a.5.5 0 01-.5-.5v-1zM7.5 9a.5.5 0 00-.5.5v1a.5.5 0 00.5.5h1a.5.5 0 00.5-.5v-1a.5.5 0 00-.5-.5h-1zM11 5.5a.5.5 0 01.5-.5h1a.5.5 0 01.5.5v1a.5.5 0 01-.5.5h-1a.5.5 0 01-.5-.5v-1zm.5 3.5a.5.5 0 00-.5.5v1a.5.5 0 00.5.5h1a.5.5 0 00.5-.5v-1a.5.5 0 00-.5-.5h-1z",
                        clip_rule: "evenodd"
                      )
                    end
                    if Current.user.user?
                      plain Current.user.tenant.name
                    else
                      link_to Current.user.tenant.name, helpers.edit_tenant_path(Current.user.tenant), class: "mort-link-primary"
                    end
                  end
                  render SessionInformation.new Current.user

                  # dt(class: "sr-only") { "Tenant status" }
                  # dd(
                  #   class:
                  #     "mt-3 flex items-center text-sm font-medium capitalize text-gray-500 sm:mr-6 sm:mt-0"
                  # ) do
                  #   svg(
                  #     class: "mr-1.5 h-5 w-5 flex-shrink-0 text-green-400",
                  #     viewbox: "0 0 20 20",
                  #     fill: "currentColor",
                  #     aria_hidden: "true"
                  #   ) do |s|
                  #     s.path(
                  #       fill_rule: "evenodd",
                  #       d:
                  #         "M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z",
                  #       clip_rule: "evenodd"
                  #     )
                  #   end
                  #   plain " Verified tenant"
                  # end
                end
              end
            end
          end
          # div(class: "mt-6 flex space-x-3 md:ml-4 md:mt-0") do
          #   link_to(I18n.t("profile.invite_new_user"), helpers.users_invitations_new_url, class: "mort-btn-primary", role: "menuitem", tabindex: "-1", id: "user-menu-item-0") unless Current.user.user?
          # end
          # div(class: "mort-field ml-2 ") do
          #   form(class: "group m-0", data: { profile_target: "buttonForm" }) do
          #     button(id: "enable_notifications", class: "hidden mort-btn-primary group-aria-busy:bg-white", type: "submit",
          #       data: {
          #         action: "click->profile#enable",
          #         profile_target: "enableNotifications"
          #       }) do
          #         span(class: "group-aria-busy:hidden block") { I18n.t("enable_notifications") }
          #         div(class: "group-aria-busy:block hidden") do
          #           image_tag "motion-blur.svg", class: "size-6 fill-white"
          #         end
          #       end
          #   end
          #   div(data: { profile_target: "disableNotifications" }) { } # empty div to keep profile_controller.js happy
          # end
          # div(class: "mort-field ml-2") do
          #   render TwoFactorField.new button_only: true, dashboard: true
          # end
        end
      end
    end
  end

  def salutation
    user_name = Current.user.name
    case Time.now.hour
    when 0..4; I18n.t("salutations.good_night", name: user_name)
    when 5..11; I18n.t("salutations.good_morning", name: user_name)
    when 12..17; I18n.t("salutations.good_afternoon", name: user_name)
    when 18..23; I18n.t("salutations.good_evening", name: user_name)
    end
  end
end
