class Users::ConfirmationsController < MortimerController
  allow_unauthenticated_access only: %i[ new create update ]

  def new
  end

  def create
    user = User.find_by(email: confirmation_params[:email])
    if user && !user.confirmed?
      user.send_confirmation_instructions
      flash[:notice] = I18n.t("devise.confirmations.send_instructions")
    else
      flash[:warning] = I18n.t("devise.confirmations.send_paranoid_instructions")
    end
    respond_to do |format|
      format.turbo_stream { render turbo_stream: [
        turbo_stream.replace("new_confirmation", partial: "users/sessions/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
        turbo_stream.replace("flash_container", partial: "application/flash_message")
      ] ; flash.clear}
      format.html         { redirect_to new_users_session_url }
    end
  end

  def update
    @user = User.find_by(confirmation_token: params[:token])

    if @user
      @user.confirm!
      @user.confirmed!
      flash[:notice] = I18n.t("devise.confirmations.confirmed")
    else
      flash[:warning] = I18n.t("devise.failure.already_confirmed")
    end
    respond_to do |format|
      format.turbo_stream { render turbo_stream: [
        turbo_stream.replace("new_confirmation", partial: "users/sessions/new", locals: { resource: User.new, resource_class: User, resource_name: "user" }),
        turbo_stream.replace("flash_container", partial: "application/flash_message")
      ] ; flash.clear}
      format.html         { redirect_to new_users_session_url }
    end
  end

  private
    def confirmation_params
      params.expect(user: [ :email ])
    end
end
