class Pos::EmployeeController < Pos::PosController
  before_action :verify_employee, only: [ :show, :edit, :create, :update, :destroy ]
  before_action :employee_time_zone, only: [ :edit ]

  layout -> { PosEmployeeLayout }

  def index
    @employees = Employee.by_account()
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
  # "punch"=>{"from_at"=>"2024-05-06T07:20", "to_at"=>"2024-05-06T15:20"}, "api_key"=>"YqymK1swsjkqSSeG3DFVjq1d", "controller"=>"pos/employee", "action"=>"create"} permitted: false>
  #
  # Manuel entry of sick/free
  #  "punch"=>{"from_at"=>"2024-05-06", "to_at"=>"2024-05-06", "reason"=>"nursing_sick"}, "api_key"=>"YqymK1swsjkqSSeG3DFVjq1d", "controller"=>"pos/employee", "action"=>"create"} permitted: false>
  def create
    if params[:employee].present?
      if params[:employee][:state] == @resource.state
        redirect_to pos_employee_url(api_key: @resource.access_token), warning: t("state_eq_current_state") and return
      end
      @resource.punch nil, employee_params[:state], request.remote_ip
      @resource.update state: employee_params[:state]
      redirect_to pos_employee_url(api_key: @resource.access_token) and return
    else
      unless @resource.out?
        redirect_to pos_employee_url(api_key: @resource.access_token), warning: t("employee_working_punch_out_first") and return
      end
      @resource.punch_range punch_params[:reason], request.remote_ip, punch_params[:from_at], punch_params[:to_at]
      redirect_to pos_employee_url(api_key: @resource.access_token, tab: "payroll") and return
    end
  rescue ActionController::InvalidAuthenticityToken => e
    redirect_to pos_employee_url(api_key: @resource.access_token), alert: t("invalid_authenticity_token") and return
  end

  #
  # update could update the employee profile
  # or update a punch
  #
  def update
    if params[:punch].present?
      @punch = Punch.find(params[:id])
      @punch.update(punch_params)
      render turbo_stream: turbo_stream.replace("punch_#{@punch.id}", partial: "pos/employee/punch", locals: { punch: @punch })
    else
      if @resource.update(employee_params)
        redirect_to pos_employee_url(api_key: @resource.access_token, tab: "profile"), success: I18n.t("employee.update.success")
      else
        redirect_to pos_employee_url(api_key: @resource.access_token, tab: "profile"), alert: I18n.t("employee.update.failed")
      end
    end
  end

  def destroy
    if params[:all].present?
      @resource.punch_cards.where(work_date: params[:date]).destroy_all
      redirect_to pos_employee_url(api_key: @resource.access_token, tab: "payroll") and return
    else
      Punch.find(params[:id]).destroy!
      redirect_to pos_employee_url(api_key: @resource.access_token, tab: "payroll") and return
    end
  end

  private
    def employee_params
      params.require(:employee).permit(:state, :name, :description, :email, :cell_phone)
    end

    def punch_params
      params.require(:punch).permit(:reason, :from_at, :to_at, :punched_at)
    end

    def verify_employee
      @resource = case true
      when params[:api_key].present?; Employee.by_account.find_by(access_token: params[:api_key])
      # when params[:employee].present?; Employee.by_account.find(params[:employee][:id])
      # when params[:q].present?; Employee.by_account.find_by(pincode: params[:q])
      else nil
      end
      redirect_to root_path and return unless @resource
    end

    def employee_time_zone(&block)
      timezone = @resource.time_zone rescue nil
      timezone.blank? ?
        Time.use_zone("UTC", &block) :
        Time.use_zone(timezone, &block)
    end
end
