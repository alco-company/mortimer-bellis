class BackgroundJobsController < MortimerController
  #
  # def mission_control
  # end
  def run
    resource.run_job if Current.get_user.superadmin? rescue false
    Broadcasters::Resource.new(resource, params.permit!, user: Current.get_user).replace
    respond_to do |format|
      format.turbo_stream { head :ok }
    end
  end

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
