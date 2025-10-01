# frozen_string_literal: true

class SessionsController < BaseController
  include TimezoneLocale
  before_action :require_authentication, only: [ :check ]

  # called by the client side to check if the session is still valid
  def check
    Session.check_session_length
    head(:ok)

  rescue MortimerExceptions::SessionExpiredError
    terminate_session # sign_out(Current.user)
    flash.now[:alert] = "Your session has expired. Please sign in again."
    redirect_to new_users_session_url
  rescue MortimerExceptions::SessionExpiringError
    Current.user.notify(action: :session_expiring, title: "Session expiring!", msg: I18n.t("sign_out_in_session_expires_shortly"))
    head(:ok)
  rescue MortimerExceptions::SessionExpiringSoonError
    flash.now[:notice] = "Your session is expiring soon. Please save your work."
    respond_to do |format|
      format.html { head :ok }
      format.json { head :ok }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }) }
    end
    flash.clear

  rescue => e
    Rails.logger.error("Session length check failed: #{e.message}")

    # return unless Current.user

    # expires_at = Current.user.last_sign_in_at + Current.tenant.get_session_timeout
    # if Time.now > expires_at
    #   sign_out(Current.user)
    #   head :unauthorized
    # else
    #   case true
    #   when expires_at < 1.hour.since
    #     Current.user.notify(action: :session_expiring, title: "Session expiring!", msg: I18n.t("sign_out_in_session_expires_shortly"))
    #   when expires_at < 10.minutes.since
    #     flash.now[:notice]= I18n.t("sign_out_in_session_expires_shortly")
    #     render turbo_stream: turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
    #   end
    #   head :ok
    # end
  rescue => e
    head :unauthorized
  end
end
