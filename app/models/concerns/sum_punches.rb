module SumPunches
  extend ActiveSupport::Concern

  class_methods do
    def recalculate(employee, across_midnight = false, date = Date.current)
      begin
        date = date.yesterday if across_midnight
        pc = PunchCard.where(account: Current.account, employee: employee, work_date: date).first_or_create
        unless pc.nil?
          punches = employee.punches.where(punched_at: date.beginning_of_day..Date.current.end_of_day).order(punched_at: :desc)
          case punches.size
          when 0; strange_no_punches
          when 1; one_punch pc, punches, employee, across_midnight
          when 2; two_punches pc, punches
          else; more_punches pc, punches, employee
          end if punches.any?
        end
      rescue => e
        say e
      end
    end

    def strange_no_punches
      say "No punches found for #{employee.name} on #{date} - which is weird (considering where we're at right now!"
    end

    def one_punch(pc, punches, employee, across_midnight)
      # we can't do anything with a single punch if we're across midnight
      return if across_midnight

      return PunchCard.recalculate(employee, true) unless punches.first.state == "IN"
      # this is the only punch of the day, so we'll calculate the time from the punch to now - 
      # and come back and do it again when the employee punches out
      pc.update work_minutes: (DateTime.current.to_i - punches.first..punched_at.to_i) / 60
    end

    def two_punches pc, punches
      return unless punches.second.state == "IN" && punches.first.state == "OUT"
      pc.update work_minutes: (punches.first.punched_at - punches.second.punched_at) / 60
    end

    def more_punches pc, punches, employee
      counters = { work: [], break: [] }
      stop = punches.first.punched_at
      punches.each_with_index do |punch,i|
        next if i == 0

        case punch.state
        when "BREAK"; counters[:break] << ((stop.to_i - punch.punched_at.to_i) / 60)
        when "IN"; counters[:work] << ((stop.to_i - punch.punched_at.to_i) / 60)
        end
        stop = punch.punched_at
      end
      work, ot1, ot2 = employee.divide_minutes counters[:work].sum
      pc.update work_minutes: work, ot1_minutes: ot1, ot2_minutes: ot2, break_minutes: counters[:break].sum
    end
  end

  included do
  end
end
