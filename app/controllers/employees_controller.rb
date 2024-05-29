class EmployeesController < MortimerController
  def new
    @resource.locale = Current.user.locale
    @resource.time_zone = Current.user.time_zone
    super
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params[:employee][:payroll_employee_ident] = Employee.next_payroll_employee_ident(params[:employee][:payroll_employee_ident])
      params.require(:employee).permit(
        :account_id,
        :team_id,
        :name,
        :mugshot,
        :pincode,
        :payroll_employee_ident,
        :punching_absence,
        :access_token,
        :last_punched_at,
        :state,
        :punches_settled_at,
        :job_title,
        :birthday,
        :hired_at,
        :description,
        :email,
        :cell_phone,
        :pbx_extension,
        :contract_minutes,
        :contract_days_per_payroll,
        :contract_days_per_week,
        :flex_balance_minutes,
        :hour_pay,
        :ot1_add_hour_pay,
        :ot2_add_hour_pay,
        :hour_rate_cent,
        :ot1_hour_add_cent,
        :ot2_hour_add_cent,
        :tmp_overtime_allowed,
        :eu_state,
        :blocked,
        :locale,
        :time_zone
      )
    end
end
