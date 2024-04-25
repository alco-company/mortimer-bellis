class TeamsController < MortimerController
  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:team).permit(:account_id, :name, :team_color, :locale, :time_zone, :punches_settled_at)
    end
end
