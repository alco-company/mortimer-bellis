class Pos::PunchClockController < Pos::PosController

  skip_before_action :verify_employee, only: :show

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
end
