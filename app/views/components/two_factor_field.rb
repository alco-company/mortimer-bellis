class TwoFactorField < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Routes

  def initialize(button_only: false, dashboard: false)
    @button_only = button_only
    @dashboard = dashboard
  end

  def view_template
    if @button_only
      div(id: "two_factor_field_button", class: %(ml-6 mt-0 flex-shrink-0)) do
        if Current.user.two_factor_app_enabled
          link_to(
            I18n.t("devise.second_factor.disable_2fa"),
            new_destroy_user_two_factor_app_url(button_only: true),
            data: { turbo_stream: true },
            class: "mort-btn-primary bg-yellow-500") unless @dashboard
        else
          link_to I18n.t("devise.second_factor.enable_2fa"), init_new_user_two_factor_app_url(button_only: true), data: { turbo_stream: true }, class: "mort-btn-primary"
        end
      end
    else
      div(id: "two_factor_field", class: %(rounded-md bg-sky-100 px-6 py-5 flex items-start justify-between)) do
        div(class: %(flex items-start)) do
          render Icons::GoogleAuthenticator.new
        end
        div(class: "ml-4 mt-0 flex-col") do
          div(class: %(text-sm font-medium text-gray-900)) { I18n.t("devise.second_factor.authenticator_app") }
          div(class: %(mt-1 text-sm text-gray-600 flex items-center)) do
            if Current.user.two_factor_app_enabled
              div do
                span(class: "block") { I18n.t("devise.second_factor.enabled") }
                span(class: "block") { I18n.l(Current.user.two_factor_app_enabled_at, format: :date) }
                span(class: %(hidden sm:inline)) { Current.user.two_factor_app_enabled_at.strftime("%H:%M") }
              end
            else
              div { I18n.t("devise.second_factor.disabled") }
            end
            div(id: "two_factor_field_button", class: %(ml-6 mt-0 flex-shrink-0)) do
              if Current.user.two_factor_app_enabled
                link_to I18n.t("devise.second_factor.disable"), new_destroy_user_two_factor_app_url, data: { turbo_stream: true }, class: "mort-btn-alert"
              else
                link_to I18n.t("devise.second_factor.enable"), init_new_user_two_factor_app_url, data: { turbo_stream: true }, class: "mort-btn-primary"
              end
            end
          end
        end
      end
    end
  end
end
