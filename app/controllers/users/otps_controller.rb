class Users::OtpsController < MortimerController
  def new
    @user = Current.user
    @qr_code = @user.qr_code
  end

  def edit
    @user = Current.user
  end

  def index
  end

  def create
    @user = Current.user
    if @user.authenticate_otp(params[:otp_code])
      @user.update!(otp_enabled: true)
      redirect_to root_path, notice: "Two-factor authentication has been enabled."
    else
      render :new
    end
  end

  def show
  end

  def update
    @user = Current.user
    otp_code = params[:otp_code]
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
