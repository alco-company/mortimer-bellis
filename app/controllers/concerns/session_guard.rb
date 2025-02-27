module SessionGuard
  extend ActiveSupport::Concern

  included do
    before_action :check_session_length
  end

  def check_session_length
    return unless Current.user

    expires_at = Current.user.last_sign_in_at + 7.days
    if Time.now > expires_at
      terminate_session
      redirect_to new_users_session_url, warning: I18n.t("session_expired")
    end
  end
end
