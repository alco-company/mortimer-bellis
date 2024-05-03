class Pos::EmployeeController < Pos::PosController
  # before_action :verify_employee, except: :show

  layout -> { PosEmployeeLayout }


  def index
    @employees = Employee.by_account
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
    def verify_token
      # api_key = case true
      # when params[:api_key].present?; params.delete(:api_key)
      # when params[:punch_card].present?; params[:punch_card].delete(:api_key)
      # end
    end
end
