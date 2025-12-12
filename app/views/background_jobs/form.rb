class BackgroundJobs::Form < ApplicationForm
  def view_template(&)
    view_only field(:tenant_id).input(value: model.tenant&.name)
    view_only field(:user_id).input(value: model.user&.name) if model.user
    row field(:job_klass).select(BackgroundJob.job_klasses, class: "mort-form-select").focus
    row field(:state).select(BackgroundJob.BACKGROUND_STATES, class: "mort-form-select")
    row field(:params).textarea(class: "mort-form-text")
    row field(:schedule).textarea(class: "mort-form-text", help: t("background_jobs.form.schedule_help"))
    row field(:next_run_at).datetime(class: "mort-form-datetime")
    view_only field(:job_id).input()
  end
end
