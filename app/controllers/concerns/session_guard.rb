module SessionGuard
  extend ActiveSupport::Concern

  included do
    before_action :check_session_length
  end

  def check_session_length
    return unless user_signed_in?

    expires_at = Current.user.last_sign_in_at + 7.days
    if Time.now > expires_at
      sign_out(current_user)
      redirect_to new_user_session_path, warning: I18n.t("session_expired")
    end
  end
end
