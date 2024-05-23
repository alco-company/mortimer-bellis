class Pos::PunchesController < Pos::PosController
  # before_action :verify_employee, only: :index
  layout false

  def index
    first_punch = Punch.find(params[:id])
    @resource = first_punch.punch_clock
    if first_punch
      employee = first_punch.employee
      date_range = first_punch.punched_at.beginning_of_day..first_punch.punched_at.end_of_day
      @punches = Punch.where(employee: employee, punched_at: date_range)
      render turbo_stream: turbo_stream.replace("date_#{helpers.dom_id(first_punch)}", partial: "pos/punches/index")
    else
      head :not_found
    end
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
end
