# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include TimezoneLocale
  before_action :configure_sign_in_params, only: [ :create ]
  before_action :authenticate_user!, only: [ :check ]

  def check
    return unless user_signed_in?

    if Time.now > Current.user.last_sign_in_at + 7.days
      sign_out(Current.user)
      head :unauthorized
    else
      head :ok
    end
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    ActiveRecord::Base.connected_to(role: :writing) do
      if sign_in_params[:otp_attempt].nil?
        user = attempting_user
        if user&.otp_required_for_login
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("otp_attempt_outlet", partial: "users/sessions/otp_attempt")
            end
          end
          return
        end
      end
      super
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

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: [ :otp_attempt ])
    end
end
