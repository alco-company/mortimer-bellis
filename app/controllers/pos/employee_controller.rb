class Pos::EmployeeController < Pos::PosController
  before_action :verify_employee, only: :show

  # layout -> { PosEmployeeLayout }

  def index
    @employees = Employee.by_account()
  end

  # #
  # # {"api_key"=>"[FILTERED]", "q"=>"1234", "id"=>"1"}
  # def edit
  # end

  # #
  # # Parameters: {"authenticity_token"=>"[FILTERED]", "punch_clock"=>{"api_key"=>"[FILTERED]"}, "employee"=>{"state"=>"IN", "id"=>"1"}, "button"=>"", "id"=>"1"}
  # def create
  #   @employee.punch @resource, params[:employee][:state], request.remote_ip
  #   redirect_to pos_punch_clock_url(api_key: @resource.access_token)
  # end

  private
    def verify_employee
      @resource = case true
      when params[:api_key].present?; Employee.by_account.find_by(access_token: params[:api_key])
      # when params[:employee].present?; Employee.by_account.find(params[:employee][:id])
      # when params[:q].present?; Employee.by_account.find_by(pincode: params[:q])
      else nil
      end
      redirect_to root_path and return unless @resource
    end
end
