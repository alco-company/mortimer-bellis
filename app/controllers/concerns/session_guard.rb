module SessionGuard
  extend ActiveSupport::Concern

  included do
    before_action :check_session_length
  end

  def check_session_length
    Session.check_session_length

  rescue MortimerExceptions::SessionExpiredError
    Authentication::Terminator.terminate_user_session
    flash[:alert] = "Your session has expired. Please sign in again."
    redirect_to new_users_session_url
  rescue MortimerExceptions::SessionExpiringError
    flash.now[:alert] = "Your session is about to expire. Please sign out and sign in again."
    # render turbo_stream: turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
    # flash.clear
  rescue MortimerExceptions::SessionExpiringSoonError
    flash.now[:notice] = "Your session is expiring soon. Please save your work."
    # respond_to do |format|
    #   format.html { head :ok }
    #   format.json { head :ok }
    #   format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }) }
    # end
    # flash.clear
  rescue => e
    Rails.logger.error("Session length check failed: #{e.message}")
  end
end
