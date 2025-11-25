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
    job.run_job
    Broadcasters::Resource.new(job, job.get_parms, user: job.tenant.users.first, stream: "#{job.tenant.id}_background_jobs").replace
  end


  # def prepare_state_job
  #   Tenant.all.each do |tenant|
  #     if tenant.users.any?
  #       UserStateJob.perform_later tenant: tenant
  #     end
  #   end
  # end

  # def prepare_eu_state_job
  #   Tenant.all.each do |tenant|
  #     if tenant.users.any?
  #       UserEuStateJob.perform_later tenant: tenant
  #     end
  #   end
  # end

  # def prepare_auto_punch_job
  #   Tenant.all.each do |tenant|
  #     if tenant.users.any?
  #       UserAutoPunchJob.perform_now tenant: tenant
  #     end
  #   end
  #   true
  # end
  # #
  # # from the solid_queue.yml
  # # this method gets called by the dispatcher every minute
  # #
  # # it goes through all the background_jobs and schedules them
  # # if their schedule is due
  # #
  # # regarding schedules/timezones - this is UTC land - and that's what
  # # any dates arriving should be considered to be!
  # #
  # # def perform(*args)
  # #   # push jobs set to run already
  # #   begin
  # #     all
  # #       .where("active=true and job_id is null and next_run_at is not null and next_run_at <= ?", DateTime.current)
  # #       .map &:run_job
  # #   rescue => error
  # #     UserMailer.error_report(error, "BackgroundJob.prepare").deliver_later
  # #   end

  # #   # push jobs not yet set to run
  # #   begin
  # #     all
  # #       .where(job_id: nil, active: true)
  # #       .map &:run_or_plan_job
  # #   rescue => error
  # #     UserMailer.error_report(error, "BackgroundJob.prepare").deliver_later
  # #   end
  # # end
end
