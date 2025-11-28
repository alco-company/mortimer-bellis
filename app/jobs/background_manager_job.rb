class BackgroundManagerJob < ApplicationJob
  queue_as :default

  #
  #
  def perform
    BackgroundJob.any_jobs_to_run.each do |job|
      case true
      when job.un_planned?; plan_job(job)
      when job.planned?; run_job(job) if job.next_run_at.nil? || job.next_run_at <= Time.current
      end
    end
  rescue => error
    ::UserMailer.error_report(error.to_s, "BackgroundManagerJob.perform").deliver_later
  end

  def plan_job(job)
    job.plan_job
    Broadcasters::Resource.new(job, job.get_parms, user: job.tenant.users.first, stream: "#{job.tenant.id}_background_jobs").replace
  end

  def run_job(job)
    return if job.shouldnt? :run
    job.run_job
    Broadcasters::Resource.new(job, job.get_parms, user: job.tenant.users.first, stream: "#{job.tenant.id}_background_jobs").replace
  end
end
