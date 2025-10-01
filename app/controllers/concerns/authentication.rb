module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
    helper_method :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  class Terminator
    def self.terminate_user_session
      Current.user.update(current_sign_in_at: nil, current_sign_in_ip: nil)
      Current.session.destroy
      # cookies.delete(:session_id)
    end
  end

  private
    def authenticated?
      resume_session && Current.session.user.confirmed?
    end

    def current_user
      Current.user ||= Current.session.user if authenticated?
    end

    def require_authentication
      if resume_session
        verify_otp_status
        request_confirmation unless Current.user.confirmed?
      else
        request_authentication
      end
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_confirmation
      redirect_to root_url, alert: "Please confirm your email address to continue."
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      flash[:alert] = "You must be logged in to access this page"
      redirect_to new_users_session_url
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      welcome_tenant(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, authentication_strategy: "password").tap do |session|
        Current.session = session
        Current.user.update(sign_in_count: Current.user.sign_in_count + 1,
          current_sign_in_at: Time.current,
          current_sign_in_ip: request.remote_ip,
          last_sign_in_at: Time.current,
          last_sign_in_ip: request.remote_ip)

        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def verify_otp_status
      # return if request.path =~ /^\/otp/
      # if Current.session.present? && !session[:otp_passed] && Current.user.otp_enabled
      #   redirect_to edit_users_otp_url(id: Current.user.id)
      # end
    end

    def terminate_session
      Current.user.update(current_sign_in_at: nil, current_sign_in_ip: nil)
      Current.session.destroy
      cookies.delete(:session_id)
    end

    def welcome_tenant(user)
      if user == user.tenant.users.first && user.sign_in_count == 0
        TenantMailer.with(tenant: user.tenant).welcome.deliver_later
      end
    end
end
