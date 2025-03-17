class TwoFactorField < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Routes

  def initialize(button_only: false, dashboard: false, link_only: false)
    @button_only = button_only
    @dashboard = dashboard
    @link_only = link_only
  end

  def view_template
    if @button_only
      css = @link_only ? "flex mort-link-primary" : "mort-btn-primary"
      div(id: "two_factor_field_button", class: %( mt-0 flex-shrink-0)) do
        if Current.user.otp_enabled
          link_to(
            I18n.t("devise.second_factor.disable_2fa"),
            users_otp_url(button_only: true),
            data: { method: :delete },
            class: "#{css} bg-yellow-500") unless @dashboard
        else
          link_to(new_users_otp_url(button_only: true), data: { turbo_stream: true }, class: css) do
            span(class: "text-sm mr-2") { I18n.t("devise.second_factor.enable_2fa") }
            render Icons::Link.new css: "mort-link-primary h-6 "
          end
        end
      end
      render Icons::ChevronUp.new css: "mort-link-primary h-6 rotate-180 cursor-pointer", data: { action: "click->hidden-description#toggle" }
    else
      div(id: "two_factor_field", class: %(rounded-md bg-sky-100 px-6 py-5 flex items-start justify-between)) do
        div(class: %(flex items-start)) do
          render Icons::GoogleAuthenticator.new
        end
        div(class: "ml-4 mt-0 flex-col") do
          div(class: %(text-sm font-medium text-gray-900)) { I18n.t("devise.second_factor.authenticator_app") }
          div(class: %(mt-1 text-sm text-gray-600 flex items-center)) do
            if Current.user.otp_enabled
              div do
                span(class: "block") { I18n.t("devise.second_factor.enabled") }
                span(class: "block") { I18n.l(Current.user.otp_enabled_at, format: :date) }
                span(class: %(hidden sm:inline)) { Current.user.otp_enabled_at.strftime("%H:%M") }
              end
            else
              div { I18n.t("devise.second_factor.disabled") }
            end
            div(id: "two_factor_field_button", class: %(ml-6 mt-0 flex-shrink-0)) do
              if Current.user.otp_enabled
                link_to I18n.t("devise.second_factor.disable_2fa"), users_otp_url, method: :delete, data: { turbo_stream: true }, class: "mort-btn-alert"
              else
                link_to I18n.t("devise.second_factor.enable_2fa"), new_users_otp_url, data: { turbo_stream: true }, class: "mort-btn-primary"
              end
            end
          end
        end
      end
    end
  end
end
