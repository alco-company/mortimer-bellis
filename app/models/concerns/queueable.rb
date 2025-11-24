module Queueable
  extend ActiveSupport::Concern

  included do
    ##
    # once saved - make sure this job is getting
    # planned to run
    #
    # after_save :plan_job

    #
    # when the background_job has performed
    # it will callback and make sure the job_id
    # is reset and next run is scheduled
    def job_done
      begin
        finished! unless failed?
        if schedule.blank?
          # One-time job - clear job_id and next_run_at
          persist(nil, nil)
        else
          # Recurring job - plan the next execution
          result = plan_job(false) # false = get next occurrence, not first
          result
        end
      rescue => exception
        Rails.logger.error "BackgroundJob.job_done failed due to #{exception}"
        Rails.logger.error exception.backtrace.join("\n")
        [ nil, nil ]
      end
    end

    #
    # we dropped this - but it's still here
    # so plan the next run
    def dropped_plan_next
      begin
        schedule.blank? ? persist(nil, nil) : plan_job(false)
      rescue => exception
        say "BackgroundJob.job_done failed due to #{exception}"
        [ nil, nil ]
      end
    end

    #
    # when resetting for a new 'day' remove the
    # next_run_at
    def job_reset
      persist nil, nil, 0
    end

    # if job.schedule
    # then get the next planned run, set the job to run at that time
    # and return the job id and planned run at time
    #
    def plan_job(first = true)
      return unless active?

      begin
        t = self.next_run(schedule, first)
        # When rescheduling after completion (first=false), always use the new calculated time
        # When scheduling for the first time (first=true), keep the earlier time if one exists
        if next_run_at && t && first
          t = Time.at(t).in_time_zone("UTC") < Time.at(next_run_at).in_time_zone("UTC") ? t : next_run_at
        end
        t ? run_job(t) : persist(nil, nil)
      rescue => exception
        say "BackgroundJob.plan_job failed due to #{exception}"
      end
    end

    #
    # set a job to run now
    # or later at t
    #
    # add this if deep debugging is needed:
    #
    #   if Rails.env.development?
    #     return w.new.perform o
    #   else
    #   end
    #
    def run_job(t = nil)
      begin
        return if shouldnt?(:run)
        o = set_parms
        w = job_klass.constantize
        s = 2
        id = nil
        if t
          id = (w.set(wait_until: Time.at(t).in_time_zone("UTC")).perform_later(**o)).job_id
        else
          id = (w.perform_later(**o)).job_id
          s = 3
        end
        t = Time.at(t.to_i).utc rescue nil
        persist id, t, s
      rescue => exception
        say "BackgroundJob.run_job failed due to #{exception}"
      end
    end

    def run_or_plan_job
      schedule.blank? ? run_job : plan_job
    end

    def get_parms
      set_parms
    end

    #
    # set the job params if any
    #
    # define params - "id:1,filter:'max',...,more" - eg: id:self,tenant_id:3,user_id:me
    # you can add eval arguments too - eg: date_range:eval(Date.today.beginning_of_month..Date.today.end_of_month)
    #
    # params are evaluated - so you can use self, tenant, team, me, and any other variable
    # and they will be added to the args[0] hash - eg: params="id:me,tenant:tenant" => args[0] = { id: 1, tenant: 3 }
    #
    def set_parms
      o = {}
      unless params.blank?
        params.split(",").each { |v| set_parm(o, v) }
      end
      o[:tenant] ||= tenant
      o[:user] ||= user
      o[:background_job] = self
      o
    end

    def set_parm(o, v)
      vs=v.split(":")
      case vs[0]
      when "me"; o[:user] = User.find(vs[1]) rescue user
      when "tenant"; o[:tenant] = tenant
      when "team"; o[:team] = Team.find(vs[1]) rescue user.team
      when "self"; o[:record] = self
      else o[vs[0].strip.to_sym] =  evaled_params(vs)
      end
    end

    def evaled_params(vs)
      parm=vs[1].strip
      cls=vs[0].strip.classify.constantize rescue nil
      return eval(parm) if parm =~ /^eval\((.*)\)/
      return cls.unscoped.find(parm) if parm =~ /^\d*$/ && cls
      return self.tenant if parm =~ /^tenant_id$/
      parm
    end

    #
    # if rrule contains /^RRULE*/ dechiffre the rrule
    # otherwise consider it a cron schedule - https://en.wikipedia.org/wiki/Cron#Overview
    #
    #
    def next_run(schedule, first = true)
      return nil if schedule.blank?
      schedule =~ /^RRULE/ ? self.rrule_runs(schedule, first) : self.cron_runs(schedule, first)
    end

    #
    # TODO allow execute_at to hold rrule's instructing SPEICHER as to the when
    def rrule_runs(rrule, first)
      nil
    end

    #
    # parse a cron schedule
    # crontask, dt=nil, number=0, scope='today', only_later=true
    # return the first - after DateTime.current - back
    #
    # Cron schedules are interpreted as UTC times.
    # The database stores UTC, and the UI layer is responsible for
    # displaying times in each user's local timezone.
    #
    def cron_runs(schedule, first)
      # BUG FIX: Always use index: 0 to get the next occurrence from now.
      # The 'first' parameter indicates initial scheduling vs rescheduling,
      # but both should return the next occurrence, not the second one.
      next_run = CronTask::CronTask.next_run(schedule: schedule, scope: "week", index: 0)

      # Safety check: ensure next_run is in the future (at least 10 seconds from now)
      # to prevent immediate re-execution if the job took longer than expected
      if next_run && Time.at(next_run) <= Time.current + 60.seconds
        # If the returned time is not sufficiently in the future, get the second occurrence
        next_run = CronTask::CronTask.next_run(schedule: schedule, scope: "week", index: 1)
      end

      next_run
    end

    #
    # persist job_id and next_run_at
    # and broadcast the update
    #
    def persist(job_id, next_run_at, state = 2)
      state = 5 if job_id.nil? && next_run_at.nil?
      update_columns job_id: job_id, next_run_at: next_run_at, state: state
      # broadcast_update
      [ job_id, next_run_at ]
    end
  end

  class_methods do
    #
    # we'll toggle the scheduling of background jobs by
    # scanning the Sidekiq for one particular job
    # if it's there - we'll kill it
    # otherwise we'll start it
    def toggle_preparing
      # ss = Sidekiq::ScheduledSet.new
      # jobs = ss.scan("BackgroundProcessingJob")
      # if jobs.any?
      #   self.reset_all_jobs
      #   'start'
      # else
      #   self.prepare true
      #   'stop'
      # end
    end

    # def running?
    #   # ss = Sidekiq::ScheduledSet.new
    #   # jobs = ss.scan("BackgroundProcessingJob")
    #   # jobs.any?
    # end


    #
    # reset all jobs - get ready for a new 'day'
    #
    def reset_all_jobs
      all.map &:job_reset
      self.clean_sidekiq
    end
  end
end
