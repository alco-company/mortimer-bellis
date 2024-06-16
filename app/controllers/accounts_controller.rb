class AccountsController < MortimerController
  before_action :authorize

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:account).permit(:id, :name, :account_color, :email, :logo, :pp_identification, :locale, :time_zone)
    end

    def authorize
      return if current_user.superadmin?
      redirect_to root_path, alert: t(:unauthorized) and return if current_user.user?
      redirect_to root_path, alert: t(:unauthorized) and return if params["action"] == "index"
      redirect_to root_path, alert: t(:unauthorized) and return unless params["id"] == Current.account.id.to_s
    end
end
