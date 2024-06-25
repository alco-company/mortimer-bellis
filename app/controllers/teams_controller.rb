class TeamsController < MortimerController
  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:team).permit(:account_id, 
      :name, 
      :team_color, 
      :locale, 
      :time_zone, 
      :punches_settled_at,
      :blocked, 
      :payroll_team_ident, 
      :description, 
      :email, 
      :cell_phone, 
      :pbx_extension, 
      :contract_minutes, 
      :contract_days_per_payroll, 
      :contract_days_per_week, 
      :hour_pay, 
      :ot1_add_hour_pay, 
      :ot2_add_hour_pay, 
      :tmp_overtime_allowed, 
      :eu_state, 
      :allowed_ot_minutes      
      )
    end
end
