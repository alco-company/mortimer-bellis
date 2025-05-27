class BackgroundJobsController < MortimerController
  #
  def mission_control
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(background_job: [ :id, :tenant_id, :user_id, :state, :job_klass, :params, :schedule, :next_run_at, :job_id ])
    end
end
