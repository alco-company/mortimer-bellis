class Users::SessionsController < MortimerController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  attr_accessor :attempting_user

  def new
    # flash.clear
  end

  def create
    ActiveRecord::Base.connected_to(role: :writing) do
      if otp_params[:otp_attempt].nil? && attempting_user&.otp_enabled
        show_otp_field
      else
        if attempting_user && otp_ok?
          attempting_user.confirmed? ? start_session : tell_unconfirmed
        else
          tell_input_error
        end
      end
    end
  end

  def destroy
    terminate_session
    session[:otp_passed] = false
    flash[:notice] = "You have been signed out."
    redirect_to new_users_session_url
  end

  private
    def otp_params
      params.expect(user: [ :email, :password, :otp_attempt ])
    end

    def sign_in_params
      params.expect(user: [ :email, :password ])
    end

    def attempting_user
      @attempting_user ||= User.authenticate_by(email: sign_in_params[:email], password: sign_in_params[:password])
      # email = sign_in_params[:email]
      # password = sign_in_params[:password]
      # user = User.find_by(email: email)
      # unless user&.valid_password?(password)
      #   return nil
      # end
      # user
    end

    def otp_ok?
      !attempting_user&.otp_enabled || attempting_user.authenticate_otp(otp_params[:otp_attempt])
    rescue
      false
    end



    def show_otp_field
      flash[:notice] = "Please enter your OTP code."
      render turbo_stream: [
        turbo_stream.replace("otp_attempt_outlet", partial: "users/sessions/otp_attempt"),
        turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
      ]
      flash.clear
    end

    def start_session
      start_new_session_for attempting_user
      Current.session.password!
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("body", partial: "users/sessions/redirect") }
        format.html         { redirect_to after_authentication_url }
      end
    end

    def tell_unconfirmed
      flash[:alert] = I18n.t("devise.failure.unconfirmed")
      # , alert: "<span>Your account is not confirmed.<span> #{view_context.link_to("Resend confirmation email?", new_confirmation_url(email: user.email), class: "underline text-sky-500")}".html_safe
      respond_to do |format|
        format.turbo_stream { render turbo_stream: [
          turbo_stream.replace("new_session", partial: "users/sessions/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
          turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
        ] ; flash.clear}
        format.html         { redirect_to new_users_session_url }
      end
    end

    def tell_input_error
      otp_params[:otp_attempt].present? ? flash[:alert] = I18n.t("devise.second_factor.bad_otp_or_password") : flash[:alert] = I18n.t("devise.failure.invalid")
      respond_to do |format|
        format.turbo_stream { render turbo_stream: [
          turbo_stream.replace("new_session", partial: "users/sessions/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
          turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
        ] ; flash.clear}

        format.turbo_stream { render turbo_stream:  }
        format.html         { redirect_to new_users_session_url }
      end
      # redirect_to new_users_session_url, alert: "Try another email address or password."
    end
end
