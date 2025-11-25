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
        if schedule.blank?
          # One-time job - mark as finished and clear job_id and next_run_at
          # Use update! instead of persist to trigger callbacks that cancel the ActiveJob
          update!(state: :finished, job_id: nil, next_run_at: nil) unless failed?
        else
          # Recurring job - plan the next execution BEFORE marking as finished
          # (plan_job requires active? to be true)
          # Skip permission check since this job is already running and rescheduling itself
          Rails.logger.info "BGJ --------------------------------- BackgroundJob.job_done: job_id=#{job_id}, background_job_id=#{id}"
          result = plan_job(false, skip_permission_check: true) # false = get next occurrence, not first
          Rails.logger.info "BGJ --------------------------------- BackgroundJob.job_done: planned next run, result=#{result.inspect}"
          # Note: plan_job will update state to 'planned' via persist(), so no need to call finished!
          result
        end
      rescue => exception
        Rails.logger.error "BGJ BackgroundJob.job_done failed due to #{exception}"
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
        say "BGJ BackgroundJob.dropped_plan_next failed due to #{exception}"
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
    def plan_job(first = true, skip_permission_check: false)
      return unless active?

      begin
        t = self.next_run(schedule, first)
        # When rescheduling after completion (first=false), always use the new calculated time
        # When scheduling for the first time (first=true), keep the earlier time if one exists
        if next_run_at && t && first
          t = Time.at(t).in_time_zone("UTC") < Time.at(next_run_at).in_time_zone("UTC") ? t : next_run_at
        end
        Rails.logger.info "BGJ plan_job: schedule=#{schedule}, first=#{first}, calculated next_run=#{t}, Time.at(t)=#{Time.at(t) rescue 'ERROR'}"
        result = t ? run_job(t, skip_permission_check: skip_permission_check) : persist(nil, nil)
        result
      rescue => exception
        Rails.logger.error "BGJ plan_job failed: #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n")
        say "BGJ plan_job failed due to #{exception}"
        nil
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
    def run_job(t = nil, skip_permission_check: false)
      begin
        Rails.logger.info "BGJ tenant #{tenant&.name} settings: #{tenant&.settings&.where(key: :run)&.pluck(:value)}"
        if !skip_permission_check && shouldnt?(:run)
          Rails.logger.warn "BGJ run_job: shouldnt?(:run) returned true, aborting"
          return nil
        end
        o = set_parms
        w = job_klass.constantize
        s = 2
        id = nil
        Rails.logger.info "BGJ run_job: params=#{o.inspect}, w=#{w}, state=#{s}"
        if t
          Rails.logger.info "BGJ run_job: t=#{t}"
          id = (w.set(wait_until: Time.at(t).in_time_zone("UTC")).perform_later(**o)).job_id
          Rails.logger.info "BGJ run_job: scheduled with wait_until, id=#{id}"
        else
          id = (w.perform_later(**o)).job_id
          Rails.logger.info "BGJ run_job: later id=#{id}"
          s = 3
        end
        # Convert timestamp to Time object, but guard against nil/0 which becomes 1970-01-01
        if t
          t = Time.at(t.to_i).utc rescue nil
        end
        Rails.logger.info "BGJ run_job: job_id=#{id}, next_run_at=#{t}, state=#{s}"
        result = persist(id, t, s)
        Rails.logger.info "BGJ run_job: persist returned #{result.inspect}"
        result
      rescue => exception
        Rails.logger.error "BGJ run_job failed: #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n")
        say "BGJ run_job failed due to #{exception}"
        nil
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

      Rails.logger.info "BGJ cron_runs: schedule=#{schedule}, first=#{first}, next_run=#{next_run}, Time.at(next_run)=#{Time.at(next_run) rescue 'ERROR'}"

      # Safety check: ensure next_run is in the future (at least 10 seconds from now)
      # to prevent immediate re-execution if the job took longer than expected
      if next_run && Time.at(next_run) <= Time.current + 60.seconds
        # If the returned time is not sufficiently in the future, get the second occurrence
        next_run = CronTask::CronTask.next_run(schedule: schedule, scope: "week", index: 1)
        Rails.logger.info "cron_runs: Using index 1, next_run=#{next_run}"
      end

      next_run
    end

    #
    # persist job_id and next_run_at
    # and broadcast the update
    #
    def persist(job_id, next_run_at, state = 2)
      Rails.logger.info "BGJ persist: job_id=#{job_id}, next_run_at=#{next_run_at}, state=#{state}"
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
