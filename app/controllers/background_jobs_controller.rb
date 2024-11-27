class BackgroundJobsController < MortimerController
  before_action :authorize

  def mission_control
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(background_job: [ :id, :tenant_id, :user_id, :state, :job_klass, :params, :schedule, :next_run_at, :job_id ])
    end

    def authorize
      redirect_to root_path, alert: "fejl" unless current_user.superadmin?
    end
end
