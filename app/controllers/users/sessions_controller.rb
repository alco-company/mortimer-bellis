# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include TimezoneLocale
  before_action :configure_sign_in_params, only: [ :create ]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    ActiveRecord::Base.connected_to(role: :writing) do
      if sign_in_params[:otp_attempt].nil? && attempting_user&.otp_required_for_login
        render turbo_stream: turbo_stream.replace("otp_attempt_outlet", partial: "users/sessions/otp_attempt")
        return
      else
        # super
        self.resource = attempting_user # warden.authenticate!(auth_options)
        self.resource = otp_ok? ? resource : nil
        sign_in(resource_name, resource) unless resource.nil?
        if user_signed_in?
          respond_to do |format|
            format.turbo_stream { render turbo_stream: turbo_stream.replace("body", partial: "users/sessions/redirect") }
            format.html         { redirect_to time_materials_url }
          end
        else
          sign_in_params[:otp_attempt].present? ? flash[:alert] = I18n.t("devise.second_factor.bad_otp_or_password") : flash[:alert] = I18n.t("devise.failure.invalid")
          respond_to do |format|
            format.turbo_stream { render turbo_stream: [
              turbo_stream.replace("new_session", partial: "users/sessions/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
              turbo_stream.replace("flash_container", partial: "application/flash_message")
            ] }

            format.turbo_stream { render turbo_stream:  }
            format.html         { redirect_to new_user_session_path }
          end
        end
      end
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected
    def attempting_user
      email = sign_in_params[:email]
      password = sign_in_params[:password]
      user = User.find_by(email: email)
      unless user&.valid_password?(password)
        return nil
      end
      user
    end

    def after_sign_in_path_for(resource)
      time_materials_url
    end

    def otp_ok?
      return true if attempting_user&.otp_required_for_login.nil?
      resource.otp_secret_key == sign_in_params[:otp_attempt]
    rescue
      false
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: [ :otp_attempt ])
    end
end
