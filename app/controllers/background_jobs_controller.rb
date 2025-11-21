class BackgroundJobsController < MortimerController
  #
  # def mission_control
  # end

  def create_callback
    # Don't plan the job during create - it will be planned when the user clicks "toggle" or edits it
    # This avoids URL generation issues during Turbo Stream broadcasting
    true
  end

  def update_callback
    resource.plan_job
    true
  end


  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(background_job: [ :id, :tenant_id, :user_id, :state, :job_klass, :params, :schedule, :next_run_at, :job_id ])
    end
end
