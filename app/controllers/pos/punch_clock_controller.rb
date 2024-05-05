class Pos::PunchClockController < Pos::PosController
  before_action :verify_token
  before_action :verify_employee, except: :show

  layout -> { PosPunchClockLayout }

  def show
  end

  #
  # {"api_key"=>"[FILTERED]", "q"=>"1234", "id"=>"1"}
  def edit
  end

  #
  # Parameters: {"authenticity_token"=>"[FILTERED]", "punch_clock"=>{"api_key"=>"[FILTERED]"}, "employee"=>{"state"=>"IN", "id"=>"1"}, "button"=>"", "id"=>"1"}
  def create
    @employee.punch @resource, params[:employee][:state], request.remote_ip
    redirect_to pos_punch_clock_url(api_key: @resource.access_token)
  end

  private

    def verify_employee
      @employee = case true
      when params[:employee_id].present?; Employee.by_account.find(params.delete(:employee_id))
      when params[:employee].present?; Employee.by_account.find(params[:employee][:id])
      when params[:q].present?; Employee.by_account.find_by(pincode: params[:q])
      else nil
      end
      redirect_to pos_punch_clock_path(api_key: @resource.access_token) and return unless @employee
    end

    def verify_token
      api_key = case true
      when params[:api_key].present?; params.delete(:api_key)
      when params[:punch_card].present?; params[:punch_card].delete(:api_key)
      when params[:punch_clock].present?; params[:punch_clock].delete(:api_key)
      else ""
      end
      @resource = PunchClock.by_account.find_by(access_token: api_key)
      redirect_to root_path and return if @resource.nil?
      Current.account = @resource.account
      # @resource.regenerate_access_token
    end
end
