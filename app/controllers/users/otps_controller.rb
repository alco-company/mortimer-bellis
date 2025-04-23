class Users::OtpsController < MortimerController
  def new
    @user = Current.user
    @qr_code = @user.qr_code
    @qr_code_as_text = @user.qr_code_as_text
    @warning = ""
  end

  def edit
    @user = Current.user
  end

  def index
  end

  def create
    @user = Current.user
    if @user.authenticate_otp(params[:user][:otp_code_token])
      @user.update!(otp_enabled: true, otp_enabled_at: Time.current)
      flash[:success] = t("devise.second_factor.enabled")
      render turbo_stream: [
        turbo_stream.remove("new_form_modal"),
        turbo_stream.update("two_factor_field", partial: "users/otps/two_factor_field"),
        turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
      ]
      flash.clear
    else
      @qr_code = @user.qr_code
      @warning = t("devise.second_factor.bad_otp_or_password")
      render :new
    end
  end

  def show
    @user = Current.user
    @user.update!(otp_enabled: false, otp_enabled_at: nil)
    flash[:success] = t("devise.second_factor.disabled")
    render turbo_stream: [
      turbo_stream.update("two_factor_field", partial: "users/otps/two_factor_field"),
      turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
    ]
    flash.clear
  end

  def update
    @user = Current.user
    otp_code = params[:otp_code_token]
    if @user.authenticate_otp(otp_code)
      session[:otp_passed] = true
      Current.session.otp!
      redirect_to root_path, notice: "You have successfully authenticated with OTP."
    else
      flash[:error] = "Invalid OTP code"
      redirect_to edit_users_otp_url(@user.id)
    end
  end

  def destroy
    session[:user_id] = nil
    session[:otp_passed] = false
    redirect_to new_users_session_url, notice: "You have been logged out successfully."
  end

  private
end
