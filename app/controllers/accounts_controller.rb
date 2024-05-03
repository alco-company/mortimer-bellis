class AccountsController < MortimerController
  before_action :authorize

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:account).permit(:id, :name, :email, :pp_identification, :locale, :time_zone)
    end

    def authorize
      redirect_to root_path, alert: "fejl" unless current_user.superadmin?
    end
end
