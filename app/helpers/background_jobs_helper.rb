module BackgroundJobsHelper
  def show_background_job_toggle_label
    if Tenant.first.background_jobs.build.shouldnt? :run
      t("settings.run.start")
    else
      t("settings.run.stop")
    end
  end
end
