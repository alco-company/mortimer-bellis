module Punchable
  extend ActiveSupport::Concern
  included do
    # def todays_punches(date: Date.current)
    #   punches.where(punched_at: date.beginning_of_day..date.end_of_day).order(punched_at: :desc)
    # end

    # def minutes_today_up_to_now
    #   counters = { work: [], break: [] }
    #   stop = DateTime.current
    #   todays_punches.pluck(:state, :punched_at).each_with_index do |punch, i|
    #     case punch[0]
    #     when "break"; counters[:break] << ((stop.to_i - punch[1].to_i) / 60)
    #     when "in"; counters[:work] << ((stop.to_i - punch[1].to_i) / 60)
    #     end
    #     stop = punch[1]
    #   end
    #   counters[:work] = counters[:work].sum; counters[:break] = counters[:break].sum
    #   counters
    # end

    # def minutes_this_payroll_period
    #   sql = <<-SQL
    #     select
    #       sum(work_minutes) as work,
    #       sum(break_minutes) as break
    #     from
    #       punch_cards
    #     where
    #       tenant_id = #{tenant.id} and
    #       employee_id = #{id} and
    #       punches_settled_at is null
    #   SQL
    #   User.connection.select_all(sql).to_a[0]
    # end

    # def get_contract_minutes
    #   return contract_minutes if contract_minutes && contract_minutes > 0
    #   return team.contract_minutes if contract_minutes.nil?
    #   [ team.contract_minutes, contract_minutes, 0 ].max
    # rescue
    #   say "No contract minutes found for #{name}"
    #   0
    # end

    # def get_contract_days_per_week
    #   contract_days_per_week > 0 ? contract_days_per_week : team.contract_days_per_week
    # end

    # def get_contract_hours_per_day
    #   get_contract_minutes_per_day divmod 60
    # end

    # def days_per_payroll
    #   contract_days_per_payroll.blank? or contract_days_per_payroll==0 ? team.days_per_payroll : contract_days_per_payroll
    # end

    # def get_contract_minutes_per_day
    #   dpp = days_per_payroll
    #   if dpp == 0 # monthly
    #     cmpd = (get_contract_minutes * 12 / 52 / get_contract_days_per_week) rescue 0
    #   else
    #     cmpd = (get_contract_minutes / dpp / get_contract_days_per_week) rescue 0
    #   end
    #   cmpd == 0 ? 444 : cmpd # 1924/52/5 => = 7.4 * 60,
    # rescue
    #   say "No contract minutes per day found for #{name}"
    #   0
    # end

    # def get_allowed_ot_minutes
    #   return team.get_allowed_ot_minutes if allowed_ot_minutes.nil?
    #   return 24*60 if allowed_ot_minutes == 0
    #   return -1 if allowed_ot_minutes < 0
    #   [ team.get_allowed_ot_minutes, allowed_ot_minutes ].min
    # rescue
    #   say "No allowed OT minutes found for #{name}"
    #   24*60
    # end

    # def get_hour_rate_cent
    #   hour_rate_cent > 0 ? hour_rate_cent : team.hour_rate_cent
    # rescue
    #   team.hour_rate_cent
    # end

    # def get_ot1_hour_rate_cent
    #   ot1_hour_rate_cent > 0 ? ot1_hour_rate_cent : team.ot1_hour_rate_cent
    # rescue
    #   team.ot1_hour_rate_cent
    # end

    # def get_ot2_hour_rate_cent
    #   ot2_hour_rate_cent > 0 ? ot2_hour_rate_cent : team.ot2_hour_rate_cent
    # rescue
    #   team.ot2_hour_rate_cent
    # end

    # def divide_minutes(minutes)
    #   work =    [ minutes, (get_contract_minutes || 0) ].min
    #   work = minutes if work == 0 && minutes > 0
    #   gaom =   get_allowed_ot_minutes
    #   return [ minutes, 0, 0 ] if gaom < 0
    #   max_ot = [ (gaom || 0), 180 ].min
    #   ot1 =     [ [ (minutes - work), 0 ].max, max_ot ].min
    #   ot2 =     [ [ (minutes - work - ot1), 0 ].max, (max_ot - ot1) ].min
    #   [ work, ot1, ot2 ]
    # end

    # def self.at_work
    #   User.where(state: [ :in, :break ]).count
    # end

    # def this_payroll_punch_cards
    #   punch_cards.where("work_date > ?", punches_settled_at.to_date).order(work_date: :desc)
    # rescue
    #   punch_cards.order(work_date: :desc)
    # end

    # def this_payroll_punches
    #   punches.where("punched_at >= ?", punches_settled_at.tomorrow.beginning_of_day).order(punched_at: :desc)
    # rescue
    #   punches.order(punched_at: :desc)
    # end

    def punch(punch_clock, state, ip, punched_at = DateTime.current)
      begin
        UserMailer.with(user: self).confetti_first_punch.deliver_later if punches.count == 0
        Punch.create! tenant: self.tenant, user: self, punch_clock: punch_clock, punched_at: punched_at, state: state, remote_ip: ip
      rescue => e
        say "Punchable#punch failed: #{e.message}"
      end
      update last_punched_at: punched_at, state: state
      # PunchCardJob.perform_later tenant: self.tenant, user: self
    rescue => e
      say "Punchable#punch (outer) failed: #{e.message}"
    end

    # # punch_params[:reason], request.remote_ip, punch_params[:from_at], punch_params[:to_at], punch_params[:comment], punch_params[:days]

    # def punch_range(params, ip)
    #   Rails.env.local? ?
    #     PunchJob.perform_now(tenant: self.tenant,
    #       reason: params["reason"] || params[:reason],
    #       ip: ip,
    #       user: self,
    #       from_date: params["from_date"] || params[:from_date],
    #       from_time: params["from_time"] || params[:from_time],
    #       to_date: params["to_date"] || params[:to_date],
    #       to_time: params["to_time"] || params[:to_time],
    #       comment: params["comment"] || params[:comment],
    #       days: params["days"] || params[:days],
    #       excluded_days: params["excluded_days"] || params[:excluded_days]) :
    #     PunchJob.perform_later(tenant: self.tenant,
    #       reason: params["reason"] || params[:reason],
    #       ip: ip,
    #       user: self,
    #       from_date: params["from_date"] || params[:from_date],
    #       from_time: params["from_time"] || params[:from_time],
    #       to_date: params["to_date"] || params[:to_date],
    #       to_time: params["to_time"] || params[:to_time],
    #       comment: params["comment"] || params[:comment],
    #       days: params["days"] || params[:days],
    #       excluded_days: params["excluded_days"] || params[:excluded_days])
    # rescue => e
    #   say "Punchable#punch_range (outer) failed: #{e.message}"
    # end

    # def did_punch(date)
    #   todays_punches(date: date).any?
    # end

    # def punch_by_calendar(date)
    #   all_calendars.each do |calendar|
    #     tz = calendar.time_zone
    #     calendar.events.each do |event|
    #       if event.occurs?({ from: date.beginning_of_week, to: date.end_of_week }, date, tz)
    #         from_at = DateTime.new date.year, date.month, date.day, event.from_time.hour, event.from_time.min, 0, tz
    #         to_at = DateTime.new date.year, date.month, date.day, event.to_time.hour, event.to_time.min, 0, tz
    #         reason = event.work_type
    #         ip = "calendar punch"
    #         PunchJob.new.punch_it!(self, reason, ip, from_at, to_at, event.comment)
    #       end
    #     end
    #   end
    #   Rails.env.local? ?
    #     PunchCardJob.perform_now(tenant: tenant, user: self, date: date) :
    #     PunchCardJob.perform_later(tenant: tenant, user: self, date: date)
    #   true
    # rescue => error
    #   UserMailer.error_report(error.to_s, "User#punch_by_calendar").deliver_later
    # end
  end
end
