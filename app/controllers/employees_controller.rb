class EmployeesController < MortimerController
  skip_before_action :authenticate_user!, only: [ :signup ]

  def new
    @resource.locale = Current.user.locale
    @resource.time_zone = Current.user.time_zone
    @resource.team = Team.by_tenant.first
    super
  end

  def show
    @punch_card_pagy, @punch_card_records = pagy(@resource.punch_cards)
    super
  end

  # POST /users/:id/archive
  def archive
    @resource = User.find(params[:id])
    if @resource
      @resource.archived? ?
        (@resource.update(state: :out) && notice = t("users.unarchived")) :
        (@resource.archived! && notice = t("users.archived"))
      redirect_back(fallback_location: root_path, notice: notice)
      Broadcasters::Resource.new(@resource).replace
    else
      redirect_back(fallback_location: root_path, warning: t("users.not_found"))
    end
  end

  def signup
    if params[:user][:api_key].present?
      api_key = params[:user].delete :api_key
      @invite = UserInvitation.find_by(access_token: api_key)
      process_signup if @invite.present?
    else
      redirect_back(fallback_location: root_path, warning: t("user_invitation.wrong_invitation"))
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      rp = params.expect(user: [ :pincode, :payroll_employee_ident ])
      params[:user][:pincode] = User.next_pincode(rp[:pincode]) if rp[:pincode].blank?
      params[:user][:payroll_employee_ident] = User.next_payroll_employee_ident(rp[:payroll_employee_ident]) if rp[:payroll_employee_ident].blank?
      params.expect(user: [
        :tenant_id,
        :team_id,
        :name,
        :mugshot,
        :country,
        :pincode,
        :user_color,
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
      ])
    end

    def process_signup
      @resource = User.new(resource_params)
      @resource.pincode = User.next_pincode()
      if @invite.completed?
        redirect_back(fallback_location: root_path, warning: t("user_invitation.already_completed"))
      else
        if @resource.save
          @invite.update state: :completed, completed_at: DateTime.current
          Broadcasters::Resource.new(@invite).replace
          UserMailer.with(user: @resource, sender: @invite.sender).pos_link.deliver_later unless @resource.email.blank?
          CompletedUserNotifier.with(record: @resource, message: "User Filled Out Their Form!").deliver(User.by_role [ :admin, :superadmin ])
          render turbo_stream: turbo_stream.replace("employee_signup", partial: "/pos/employee/signup_success")
        else
          @invite.update state: :error
          @employee = @resource
          @employee.access_token = @invite.access_token
          render "employee_invitations/employee_sign_up", status: :unprocessable_entity, warning: t("user_invitation.could_not_create_employee")
        end
      end
    end


    #
    # implement on the controller inheriting this concern
    # in order to not having to extend the create method on this concern
    #
    def create_callback
      UserMailer.with(user: @resource, sender: current_user.name).welcome.deliver_later unless @resource.email.blank?
    end
end
