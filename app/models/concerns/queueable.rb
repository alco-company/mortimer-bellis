module Queueable
  extend ActiveSupport::Concern

  included do
    ##
    # once saved - make sure this job is getting
    # planned to run
    #
    after_save :plan_job

    #
    # when the background_job has performed
    # it will callback and make sure the job_id
    # is reset
    def job_done
      begin
        schedule.blank? ? persist(nil, nil) : plan_job
      rescue => exception
        say "BackgroundJob.job_done failed due to #{exception}"
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
      persist nil, nil
    end

    # if job.schedule
    # then get the next planned run, set the job to run at that time
    # and return the job id and planned run at time
    #
    def plan_job(first = true)
      begin
        t = active? ? self.next_run(schedule, first) : nil
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
        o = set_parms
        w = job_klass.constantize
        id = t ? (w.set(wait_until: t).perform_later(**o)).job_id : (w.perform_later(**o)).job_id
        t = Time.at(t.to_i).utc rescue nil
        persist id, t
      rescue => exception
        say "BackgroundJob.run_job failed due to #{exception}"
      end
    end

    def run_or_plan_job
      schedule.blank? ? run_job : plan_job
    end

    #
    # set the job params if any
    #
    # define params - "id:1,filter:'max',...,more" - eg: id:self,account_id:3,user_id:me
    # you can add eval arguments too - eg: date_range:eval(Date.today.beginning_of_month..Date.today.end_of_month)
    #
    # params are evaluated - so you can use self, account, team, me, and any other variable
    # and they will be added to the args[0] hash - eg: params="id:me,account:account" => args[0] = { id: 1, account: 3 }
    #
    def set_parms
      o = {}
      unless params.blank?
        params.split(",").each { |v| set_parm(o, v) }
      end
      o
    end

    def set_parm(o, v)
      vs=v.split(":")
      case vs[0]
      when "me"; o[:user] = User.find(vs[1]) rescue Current.user
      when "account"; o[:account] = Current.account
      when "team"; o[:team] = Team.find(vs[1]) rescue Current.user.team
      when "self"; o[:record] = self
      else o[vs[0].strip.to_sym] =  evaled_params(vs)
      end
    end

    def evaled_params(vs)
      parm=vs[1].strip
      cls=vs[0].strip.classify.constantize rescue nil
      return eval(parm) if parm =~ /^eval\((.*)\)/
      return cls.unscoped.find(parm) if parm =~ /^\d*$/ && cls
      return self.account if parm =~ /^account_id$/
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
    def cron_runs(schedule, first)
      # crontask, dt=nil, number=0, scope='today', only_later=true
      CronTask::CronTask.next_run(schedule: schedule, scope: "week", index: (first ? 0 : 1))
    end

    #
    # persist job_id and next_run_at
    # and broadcast the update
    #
    def persist(job_id, next_run_at)
      update_columns job_id: job_id, next_run_at: next_run_at
      Current.account ||= self.account
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

    def running?
      # ss = Sidekiq::ScheduledSet.new
      # jobs = ss.scan("BackgroundProcessingJob")
      # jobs.any?
    end


    #
    # reset all jobs - get ready for a new 'day'
    #
    def reset_all_jobs
      all.map &:job_reset
      self.clean_sidekiq
    end
  end
end
