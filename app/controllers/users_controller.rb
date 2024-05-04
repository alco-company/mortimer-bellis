class UsersController < MortimerController
  before_action :authorize

  def update
    if params[:user][:role].present? &&
      !Current.user.superadmin? &&
      [ 0, "0", "superadmin", "Superadmin", "SUPERADMIN" ].include?(params[:user][:role])
      redirect_to edit_resource_url, error: "You are not authorized to change the role to superadmin." and return
    end
    super
  end
  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:user).permit(:account_id, :email, :role, :locale, :time_zone)
    end

    def authorize
      redirect_to root_path, alert: "fejl" if current_user.user?
    end
end
