module BackgroundJobsHelper
  def show_background_job_toggle_label
    if Tenant.first.background_jobs.build.shouldnt? :run
      "Start Background Jobs"
    else
      "Stop Background Jobs"
    end
  end
end
