class PunchesController < MortimerController
  # <ActionController::Parameters {
  # "punch"=>#<ActionController::Parameters {"punch_clock_id"=>"50"} permitted: true>,
  # "authenticity_token"=>"dMXypk0HuC_LRwXOX714C8ySPS9H3ScthVJ6mm-6nDdAC8jf2Kw4pH7-GtOT9cXETd77_Ch9T4YaHbXOghu2ew",
  # "controller"=>"punches",
  # "action"=>"create"
  # } permitted: true>
  def create
    punch_clock = PunchClock.find(resource_params[:punch_clock_id]) || PunchClock.where(account: Current.account).first
    Current.user.punch(punch_clock, resource_params[:state], resource_params[:remote_ip])
    render turbo_stream: turbo_stream.replace("punch_button", partial: "punches/punch_button", locals: { user: Current.user, punch_clock: punch_clock }, alert: I18n.t("punch.create.failed"))
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:punch).permit(:account_id, :user_id, :punch_clock_id, :punched_at, :state, :remote_ip, :comment)
    end

    #
    # implement on the controller inheriting this concern
    def create_callback(res)
      begin
        PunchCard.recalculate employee: res.employee, across_midnight: false, date: res.punched_at.to_date
      rescue => e
        say e
      end
    end
    def update_callback(res)
      begin
        PunchCard.recalculate employee: res.employee, across_midnight: false, date: res.punched_at.to_date
      rescue => e
         say e
      end
    end

    #
    # implement on the controller inheriting this concern
    # in order to not having to extend the update method on this concern
    #
    # this has to return a method that will be called after the destroy!!
    # ie - it cannot call methods on the object istself!
    #
    def destroy_callback(res)
      "PunchCard.recalculate( employee: Employee.find(#{res.employee.id}), across_midnight: false, date: '#{res.punched_at.to_date}')"
    end
end
