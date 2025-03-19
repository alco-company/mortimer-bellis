# frozen_string_literal: true

class SessionsController < BaseController
  include TimezoneLocale
  before_action :require_authentication, only: [ :check ]

  # called by the client side to check if the session is still valid
  def check
    # return unless Current.user

    expires_at = Current.user.last_sign_in_at + 7.days
    if Time.now > expires_at
      sign_out(Current.user)
      head :unauthorized
    else
      case true
      when expires_at < 1.hour.since
        Current.user.notify(action: :session_expiring, title: "Session expiring!", msg: I18n.t("sign_out_in_session_expires_shortly"))
      when expires_at < 10.minutes.since
        flash.now[:notice]= I18n.t("sign_out_in_session_expires_shortly")
        render turbo_stream: turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
      end
      head :ok
    end
  rescue
    head :unauthorized
  end
end
