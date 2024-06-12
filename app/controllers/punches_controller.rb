class PunchesController < MortimerController
  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:punch).permit(:account_id, :employee_id, :punch_clock_id, :punched_at, :state, :remote_ip, :comment)
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
