class Users::PasswordsController < MortimerController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
  end

  def create
    if user = User.find_by(email: params[:email])
      PasswordsMailer.reset(user).deliver_later
      flash[:notice] = I18n.t("devise.passwords.send_instructions")
    else
      flash[:warning] = I18n.t("devise.passwords.send_paranoid_instructions")
    end
    respond_to do |format|
      format.turbo_stream { render turbo_stream: [
        turbo_stream.replace("new_password", partial: "users/sessions/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
        turbo_stream.replace("flash_container", partial: "application/flash_message")
      ] }
      format.html         { redirect_to new_users_session_url }
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:notice] = I18n.t("devise.passwords.updated_not_active")
      @user.out!
      redirect_to new_users_session_path
    else
      flash[:alert] = I18n.t("devise.passwords.passwords_not_matching")
      redirect_to edit_users_password_url(params[:token])
    end
  end

  private
    def user_params
      params.expect(user: [ :password, :password_confirmation ])
    end
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_users_password_url, alert: I18n.t("devise.passwords.no_token")
    end
end
