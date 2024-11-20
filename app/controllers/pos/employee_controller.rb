class Pos::EmployeeController < Pos::PosController
  before_action :verify_employee, only: [ :index, :show, :edit, :create, :update, :destroy ]
  around_action :user_time_zone, only: [ :show, :edit, :create, :update, :destroy ]

  layout -> { PosUserLayout }

  def signup_success
  end

  def index
    @users = User.by_tenant()
  end

  def punches
    @first_punch = Punch.find(params[:id]) rescue false
    @punch_clock = (PunchClock.find(params[:punch_clock_id]) rescue false) if params[:punch_clock_id].present?
    @resource = @user = @first_punch.user
    if @first_punch
      if @punch_clock
        punch_clock_time_zone do
          render_punches
        end
      else
        employee_time_zone do
          render_punches
        end
      end
    else
      head :not_found
    end
  end

  def edit
    @punch = Punch.find(params[:id])
    render turbo_stream: turbo_stream.replace("punch_#{@punch.id}", partial: "pos/employee/edit", locals: { punch: @punch })
  end

  # #
  # # {"api_key"=>"[FILTERED]", "q"=>"1234", "id"=>"1"}
  # def edit
  # end

  # # Parameters: {"authenticity_token"=>"[FILTERED]", "employee"=>{"api_key"=>"[FILTERED]", "state"=>"in", "id"=>"122"}, "button"=>"", "api_key"=>"[FILTERED]"}
  # Manuel entry of work:
  # "punch"=>{"from_at"=>"2024-05-06T07:20", "to_at"=>"2024-05-06T15:20"}, "comment" => "en ting", "api_key"=>"YqymK1swsjkqSSeG3DFVjq1d", "controller"=>"pos/employee", "action"=>"create"} permitted: false>
  #
  # Manuel entry of sick/free
  #  "punch"=>{"from_at"=>"2024-05-06", "to_at"=>"2024-05-06", "comment" => "en ting", "reason"=>"nursing_sick"}, "api_key"=>"YqymK1swsjkqSSeG3DFVjq1d", "controller"=>"pos/employee", "action"=>"create"} permitted: false>
  def create
    redirect_to(pos_employee_url(api_key: @resource.access_token), warning: t("user.archived")) and return if @resource.archived?
    redirect_to(pos_employee_url(api_key: @resource.access_token), warning: t("user.blocked")) and return if @resource.is_blocked?

    params[:user].present? ? now_punch : range_punch
  rescue ActionController::InvalidAuthenticityToken
    redirect_to pos_employee_url(api_key: @resource.access_token), alert: t("invalid_authenticity_token") and return
  end

  #
  # update could update the employee profile
  # or update a punch
  #
  def update
    redirect_to(pos_employee_url(api_key: @resource.access_token), warning: t("user.archived")) and return if @resource.archived?
    redirect_to(pos_employee_url(api_key: @resource.access_token), warning: t("user.blocked")) and return if @resource.is_blocked?

    if params[:punch].present?
      @punch = Punch.find(params[:id])
      @punch.update(punch_params)
      PunchCard.recalculate(user: @punch.user, date: @punch.punched_at.to_date)
      render turbo_stream: turbo_stream.replace("punch_#{@punch.id}", partial: "pos/employee/punch", locals: { punch: @punch })
    else
      if @resource.update(employee_params)
        redirect_to pos_employee_url(api_key: @resource.access_token, tab: "profile"), success: I18n.t("user.update.success")
      else
        render turbo_stream: turbo_stream.replace("mortimer_form", partial: "pos/employee/profile", locals: { user: @resource }, alert: I18n.t("user.update.failed"))
      end
    end
  end

  def destroy
    redirect_to(pos_employee_url(api_key: @resource.access_token), warning: t("user.archived")) and return if @resource.archived?
    redirect_to(pos_employee_url(api_key: @resource.access_token), warning: t("user.blocked")) and return if @resource.is_blocked?

    if params[:all].present?
      @resource.punch_cards.where(work_date: params[:date]).destroy_all
      @resource.todays_punches(date: Date.parse(params[:date])).destroy_all
      redirect_to pos_employee_url(api_key: @resource.access_token, tab: "payroll") and return
    else
      punch = Punch.find(params[:id])
      if punch.punch_card && punch.punch_card.punches.size == 1
        punch.punch_card.destroy
      else
        punch.destroy
      end
      PunchCard.recalculate(user: punch.user, date: punch.punched_at.to_date)
      redirect_to pos_employee_url(api_key: @resource.access_token, tab: "payroll") and return
    end
  end

  private
    def employee_params
      params.expect(user: [ :state, :name, :description, :email, :cell_phone, :locale, :time_zone, :birthday, :mugshot ])
    end

    def punch_params
      params.expect(punch: [ :reason, :from_date, :from_time, :to_date, :to_time, :duration, :punched_at, :comment, :excluded_days, days: [ [] ] ])
    end

    def verify_employee
      api = params.permit(:api_key)[:api_key]
      @resource = case true
      when params[:api_key].present?; User.by_tenant.find_by(access_token: api)
      # when params[:user].present?; User.by_tenant.find(params[:user][:id])
      # when params[:q].present?; User.by_tenant.find_by(pincode: params[:q])
      else nil
      end
      redirect_to root_path and return unless @resource

      Current.tenant = @resource.tenant
    end

    def now_punch
      if params[:user][:state] == @resource.state
        redirect_to pos_employee_url(api_key: @resource.access_token), warning: t("state_eq_current_state", state: @resource.state) and return
      else
        case employee_params[:state]
        when "in", "break", "out"
          punch_clock = PunchClock.where(tenant: @resource.tenant).first
          @resource.punch punch_clock, employee_params[:state], request.remote_ip
          @resource.update state: employee_params[:state]
        else
          if @resource.out? && !employee_params[:state].blank?
            duration = @resource&.get_contract_minutes_per_day
            dt = Date.today
            from = DateTime.new(dt.year, dt.month, dt.day, 8, 0, 0)
            to_at = (from + duration.minutes).strftime("%H:%M")
            parms = {
              from_date: dt,
              from_time: "08:00", # Time.now.strftime("%H:%M"),
              duration: duration.minutes,
              to_date: dt,
              to_time: to_at,
              comment: "",
              reason: params[:user][:state],
              days: [],
              excluded_days: ""
            }
            @resource.punch_range parms, request.remote_ip
          end
        end
        redirect_to pos_employee_url(api_key: @resource.access_token) and return
      end
    end

    def range_punch
      begin
        if (Date.today == Date.parse(punch_params[:from_date]) ||
          Date.today == Date.parse(punch_params[:to_date])) && !@resource.out?
          redirect_to pos_employee_url(api_key: @resource.access_token), warning: t("user_working_punch_out_first") and return
        end
        @resource.punch_range punch_params, request.remote_ip
        redirect_to pos_employee_url(api_key: @resource.access_token, tab: "payroll") and return
      rescue => e
        redirect_to pos_employee_url(api_key: @resource.access_token, edit: true, tab: "payroll"), warning: t("form_not_processable") and return
      end
    end

    def render_punches
      date_range = @first_punch.punched_at.beginning_of_day..@first_punch.punched_at.end_of_day
      @punches = Punch.where(user: @user, punched_at: date_range).order(punched_at: :desc)
      render turbo_stream: turbo_stream.replace("payroll_#{helpers.dom_id(@first_punch)}", partial: "pos/punches/index")
    end

    def employee_time_zone(&block)
      return unless block_given?
      timezone = @resource.time_zone rescue nil
      begin
        timezone.blank? ?
          Time.use_zone("UTC", &block) :
          Time.use_zone(timezone, &block)
      rescue => e
        Time.use_zone("UTC", &block)
      end
    end

    def punch_clock_time_zone(&block)
      return unless block_given?
      timezone = @punch_clock.time_zone rescue nil
      begin
        timezone.blank? ?
          Time.use_zone("UTC", &block) :
          Time.use_zone(timezone, &block)
      rescue
        Time.use_zone("UTC", &block)
      end
    end
end
