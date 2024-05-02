class UsersController < MortimerController
  before_action :authorize

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:user).permit(:account_id, :email, :role, :locale, :time_zone)
    end

    def authorize
      redirect_to root_path, alert: 'fejl' if current_user.user?
    end
end
