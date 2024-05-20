module SumPunches
  extend ActiveSupport::Concern

  class_methods do
    def recalculate(employee:, across_midnight: false, date: Date.current, from_at: nil, to_at: nil, **args)
      if from_at && to_at
        (from_at.to_date..to_at.to_date).each do |d|
          recalculate employee: employee, across_midnight: across_midnight, date: d
        end
      else
        begin
          date = date.yesterday if across_midnight
          say "Recalculating #{employee.name} on #{date}"
          pc = PunchCard.where(account: employee.account, employee: employee, work_date: date).first_or_create
          unless pc.nil?
            punches = employee.punches.where(punched_at: date.beginning_of_day..date.end_of_day).order(punched_at: :desc)
            case punches.size
            when 0; strange_no_punches
            when 1; one_punch pc, punches, employee, across_midnight, date
            when 2; two_punches pc, punches
            else; more_punches pc, punches, employee
            end if punches.any?
          end
        rescue => e
          say e
        end
      end
    end

    def strange_no_punches
      say "No punches found for #{employee.name} on #{date} - which is weird (considering where we're at right now!"
    end

    def one_punch(pc, punches, employee, across_midnight, date)
      # we can't do anything with a single punch if we're across midnight
      return if across_midnight

      return PunchCard.recalculate(employee: employee, across_midnight: true, date: date) unless punches.first.in?
      # this is the only punch of the day, so we'll calculate the time from the punch to now -
      # and come back and do it again when the employee punches out'
      punches.update_all punch_card_id: pc.id
      pc.update work_minutes: (DateTime.current.to_i - punches.first..punched_at.to_i) / 60
    end

    def two_punches(pc, punches)
      punches.update_all punch_card_id: pc.id
      return unless punches.second.in? && punches.first.out?
      pc.update work_minutes: (punches.first.punched_at - punches.second.punched_at) / 60
    end

    def more_punches(pc, punches, employee)
      counters = { work: [], break: [] }
      stop = punches.first.punched_at
      punches.each_with_index do |punch, i|
        next if i == 0

        case punch.state
        when :break; counters[:break] << ((stop.to_i - punch.punched_at.to_i) / 60)
        when :in; counters[:work] << ((stop.to_i - punch.punched_at.to_i) / 60)
        end
        stop = punch.punched_at
      end
      work, ot1, ot2 = employee.divide_minutes counters[:work].sum
      punches.update_all punch_card_id: pc.id
      pc.update work_minutes: work, ot1_minutes: ot1, ot2_minutes: ot2, break_minutes: counters[:break].sum
    end
  end

  included do
  end
end
