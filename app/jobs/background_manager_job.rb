class BackgroundManagerJob < ApplicationJob
  queue_as :default

  #
  # step 1 background jobs will be running 3 jobs
  #
  #   1: employee_state_job
  #   2: employee_eu_state_job
  #   3: employee_auto_punch_job
  #
  def perform
    dt = DateTime.current
    prepare_state_job if dt.hour == 5 and dt.min == 0
    prepare_eu_state_job if dt.hour == 5 and dt.min == 5
    prepare_auto_punch_job if dt.hour == 23 and dt.min == 50
  rescue => error
    UserMailer.error_report(error.to_s, "BackgroundManagerJob.perform").deliver_later
  end

  def prepare_state_job
    Account.all.each do |account|
      EmployeeStateJob.perform_later account: account
    end
  end

  def prepare_eu_state_job
    Account.all.each do |account|
      EmployeeEuStateJob.perform_later account: account
    end
  end

  def prepare_auto_punch_job
    Account.all.each do |account|
      if account.employees.any?
        EmployeeAutoPunchJob.perform_later account: account
      end
    end
  end
  #
  # from the solid_queue.yml
  # this method gets called by the dispatcher every minute
  #
  # it goes through all the background_jobs and schedules them
  # if their schedule is due
  #
  # regarding schedules/timezones - this is UTC land - and that's what
  # any dates arriving should be considered to be!
  #
  # def perform(*args)
  #   # push jobs set to run already
  #   begin
  #     all
  #       .where("active=true and job_id is null and next_run_at is not null and next_run_at <= ?", DateTime.current)
  #       .map &:run_job
  #   rescue => error
  #     UserMailer.error_report(error, "BackgroundJob.prepare").deliver_later
  #   end

  #   # push jobs not yet set to run
  #   begin
  #     all
  #       .where(job_id: nil, active: true)
  #       .map &:run_or_plan_job
  #   rescue => error
  #     UserMailer.error_report(error, "BackgroundJob.prepare").deliver_later
  #   end
  # end
end
