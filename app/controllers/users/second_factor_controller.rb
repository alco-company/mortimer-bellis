require "rqrcode"

class Users::SecondFactorController < BaseController
  layout false

  def initiate_new_app
    say Current.user
    @password_confirmation_form = PasswordConfirmationForm.new
    @button_only = params[:button_only].present? && params[:button_only] == "true"
  end

  def new_app
    @password_confirmation_form = PasswordConfirmationForm.new(password_confirmation_params)

    @user = SecondFactor::InitializeAppProvisioning.new.call(user: Current.user, password: @password_confirmation_form.password)
    @qr_code = qr_code(@user)
    @otp_secret = @user.otp_secret
    @two_factor_app_enablement_form = TwoFactorAppEnablementForm.new(password: @password_confirmation_form.password)
    @button_only = password_confirmation_params[:button_only].present? && password_confirmation_params[:button_only] == "true"

  rescue Errors::InvalidPasswordError
    @password_confirmation_form.errors.add(:base, t("devise.second_factor.bad_password"))
    render turbo_stream: [
      turbo_stream.replace("modal_container", partial: "users/second_factor/initiate_new_app", locals: { button_only: @button_only, password_confirmation_form: @password_confirmation_form }, status: :unprocessable_entity)
    ]

  rescue Errors::TwoFactorAlreadyEnabledError
    flash.now[:warning] = t("devise.second_factor.already_enabled")
    render turbo_stream: [
      turbo_stream.replace("new_form_modal", ""),
      turbo_stream.replace("flash_container", partial: "application/flash_message")
    ]
  end

  def create_app
    @two_factor_app_enablement_form = TwoFactorAppEnablementForm.new(two_factor_app_enablement_params)

    @user = SecondFactor::ProvisionApp.new.call(
      user: Current.user,
      password: @two_factor_app_enablement_form.password,
      otp_code: @two_factor_app_enablement_form.otp_code)

    target = (two_factor_app_enablement_params[:button_only].present? && two_factor_app_enablement_params[:button_only] == "true") ? "two_factor_field_button" : "two_factor_field"

    flash.now[:success] = t("devise.second_factor.enabled")
    render turbo_stream: [
      turbo_stream.replace("new_form_modal", ""),
      turbo_stream.replace(target, partial: "users/second_factor/#{target}"),
      turbo_stream.replace("flash_container", partial: "application/flash_message")
    ]

  rescue Errors::InvalidPasswordError
    form = PasswordConfirmationForm.new(password: two_factor_app_enablement_form.password)
    form.errors.add(:base, t("devise.second_factor.bad_password"))

    render turbo_stream: [
      turbo_stream.replace("modal_container", partial: "users/second_factor/initiate_new_app", locals: { password_confirmation_form: form }, status: :unprocessable_entity)
    ]

  rescue Errors::InvalidOtpCodeError
    flash.now[:warning] = t("devise.second_factor.bad_otp_or_password")
    render turbo_stream: [
      turbo_stream.replace("new_form_modal", ""),
      turbo_stream.replace("flash_container", partial: "application/flash_message")
    ]
  end

  def new_destroy_app
    @otp_confirmation_form = OtpConfirmationForm.new
    @button_only = params[:button_only].present? && params[:button_only] == "true"
  end

  def destroy_app
    @otp_confirmation_form = OtpConfirmationForm.new(otp_confirmation_params)

    _user = SecondFactor::DisableApp.new.call(
      user: Current.user,
      otp_code: @otp_confirmation_form.otp_code)

    target = (otp_confirmation_params[:button_only].present? && otp_confirmation_params[:button_only] == "true") ? "two_factor_field_button" : "two_factor_field"
    flash.now[:success] = t("devise.second_factor.disabled")
    render turbo_stream: [
      turbo_stream.replace("new_form_modal", ""),
      turbo_stream.replace(target, partial: "users/second_factor/#{target}"),
      turbo_stream.replace("flash_container", partial: "application/flash_message")
    ]

  rescue Errors::InvalidOtpCodeError
    form = OtpConfirmationForm.new
    form.errors.add(:base, t("devise.second_factor.bad_otp_or_password"))
    render turbo_stream: [
      turbo_stream.replace("modal_container", partial: "users/second_factor/new_destroy_app", locals: { otp_confirmation_form: form }, status: :unprocessable_entity)
    ]
  end

  private
    def password_confirmation_params
      params.require(:password_confirmation_form).permit(:password, :button_only)
    end

    def two_factor_app_enablement_params
      params.require(:two_factor_app_enablement_form).permit(:password, :button_only, :otp_code)
    end

    def otp_confirmation_params
      params.require(:otp_confirmation_form).permit(:button_only, :otp_code)
    end

    # param [User] user
    def qr_code(user)
      provisioning_uri = user.otp_provisioning_uri(user.email, issuer: "Mortimer")
      RQRCode::QRCode.new(provisioning_uri, level: :l).as_svg(fill: :currentColor, color: "0ea5e9", viewbox: true)
    end
end
