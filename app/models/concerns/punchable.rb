module Punchable
  extend ActiveSupport::Concern
  included do
    def todays_punches(date: Date.current)
      punches.where(punched_at: date.beginning_of_day..date.end_of_day).order(punched_at: :desc)
    end

    def minutes_today_up_to_now
      counters = { work: [], break: [] }
      stop = DateTime.current
      todays_punches.pluck(:state, :punched_at).each_with_index do |punch, i|
        case punch[0]
        when "break"; counters[:break] << ((stop.to_i - punch[1].to_i) / 60)
        when "in"; counters[:work] << ((stop.to_i - punch[1].to_i) / 60)
        end
        stop = punch[1]
      end
      counters[:work] = counters[:work].sum; counters[:break] = counters[:break].sum
      counters
    end

    def get_contract_minutes
      return contract_minutes if contract_minutes && contract_minutes > 0
      return team.contract_minutes if contract_minutes.nil?
      [ team.contract_minutes, contract_minutes, 0 ].max
    rescue
      say "No contract minutes found for #{name}"
      0
    end

    def get_contract_days_per_week
      contract_days_per_week > 0 ? contract_days_per_week : team.contract_days_per_week
    end

    def get_contract_hours_per_day
      get_contract_minutes_per_day divmod 60
    end

    def get_contract_minutes_per_day
      dpp = contract_days_per_payroll > 0 ? contract_days_per_payroll : (team.contract_days_per_payroll || 0)
      if dpp == 0 # monthly
        get_contract_minutes * 12 / 52 / get_contract_days_per_week
      else
        get_contract_minutes / dpp / get_contract_days_per_week
      end
    rescue
      say "No contract minutes per day found for #{name}"
      0
    end

    def get_allowed_ot_minutes
      return team.get_allowed_ot_minutes if allowed_ot_minutes.nil?
      return 24*60 if allowed_ot_minutes == 0
      return -1 if allowed_ot_minutes < 0
      [ team.get_allowed_ot_minutes, allowed_ot_minutes ].min
    rescue
      say "No allowed OT minutes found for #{name}"
      24*60
    end

    def get_hour_rate_cent
      hour_rate_cent > 0 ? hour_rate_cent : team.hour_rate_cent
    rescue
      team.hour_rate_cent
    end

    def get_ot1_hour_rate_cent
      ot1_hour_rate_cent > 0 ? ot1_hour_rate_cent : team.ot1_hour_rate_cent
    rescue
      team.ot1_hour_rate_cent
    end

    def get_ot2_hour_rate_cent
      ot2_hour_rate_cent > 0 ? ot2_hour_rate_cent : team.ot2_hour_rate_cent
    rescue
      team.ot2_hour_rate_cent
    end

    def divide_minutes(minutes)
      work =    [ minutes, (get_contract_minutes || 0) ].min
      return [ work, 0, 0 ] if get_allowed_ot_minutes < 0
      max_ot = [ (get_allowed_ot_minutes || 0), 180 ].min
      ot1 =     [ [ (minutes - work), 0 ].max, max_ot ].min
      ot2 =     [ [ (minutes - work - ot1), 0 ].max, (max_ot - ot1) ].min
      [ work, ot1, ot2 ]
    end

    def self.at_work
      Employee.where(state: [ :in, :break ]).count
    end

    def this_payroll_punch_cards
      punch_cards.where("work_date > ?", punches_settled_at.to_date).order(work_date: :desc)
    rescue
      punch_cards.order(work_date: :desc)
    end

    def this_payroll_punches
      punches.where("punched_at >= ?", punches_settled_at.tomorrow.beginning_of_day).order(punched_at: :desc)
    rescue
      punches.order(punched_at: :desc)
    end

    def punch(punch_clock, state, ip, punched_at = DateTime.current)
      begin
        EmployeeMailer.with(employee: self).confetti_first_punch.deliver_later if punches.count == 0
        Punch.create! account: self.account, employee: self, punch_clock: punch_clock, punched_at: punched_at, state: state, remote_ip: ip
      rescue => e
        say "Punch failed: #{e.message}"
      end
      update last_punched_at: punched_at
      PunchCardJob.perform_later account: self.account, employee: self
    rescue => e
      false
    end

    def punch_range(reason, ip, from_at, to_at, comment = nil)
      PunchJob.perform_later account: self.account, reason: reason, ip: ip, employee: self, from_at: from_at, to_at: to_at, comment: comment
    end
  end
end
