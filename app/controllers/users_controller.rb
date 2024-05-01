class UsersController < MortimerController
 private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:user).permit(:account_id, :email, :role, :locale, :time_zone)
    end
end
