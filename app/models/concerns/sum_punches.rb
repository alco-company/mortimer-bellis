module SumPunches
  extend ActiveSupport::Concern

  class_methods do
    def recalculate(employee:, across_midnight: false, date: Date.current, from_at: false, to_at: false, **args)
      (from_at && to_at) ?
        calc_range(employee, across_midnight, date, from_at, to_at) :
        calc_date(employee, across_midnight, date)
    end

    def calc_range(employee, across_midnight, date, from_at, to_at)
      (from_at.to_date..to_at.to_date).each do |d|
        calc_date employee, across_midnight, d
      end
    end

    def calc_date(employee, across_midnight, date)
      begin
        date = date.to_date
        ActiveRecord::Base.connected_to(role: :writing) do
          # Code in this block will be connected to the writing role
          fdate = across_midnight ? date.yesterday : date
          tdate = date
          say "Recalculating #{employee.name} on #{date}"
          pc = PunchCard.where(account: employee.account, employee: employee, work_date: fdate).first_or_create
          unless pc.nil?
            begin
              punches = employee.punches.where(punched_at: fdate.beginning_of_day..tdate.end_of_day).order(punched_at: :desc)
              say "Found #{punches.size} punches for #{employee.name} on #{fdate}-#{tdate}"
              pc.update work_minutes: -1
              case punches.size
              when 0; strange_no_punches
              when 1; one_punch pc, punches, employee, across_midnight, fdate
              when 2; two_punches pc, punches, employee
              else; more_punches pc, punches, employee
              end if punches.any?

              # we'll just delete the punch card, as it's not needed - and we'll try again next time, and keep the punches
              pc.delete if pc.punches.empty?

            rescue => e
              say e
              pc.update work_minutes: -1 if pc
            end
          end
        end
      rescue => e
        say e
      end
    end

    def strange_no_punches(pc)
      say "No punches found for #{employee.name} on #{date} - which is weird (considering where we're at, right now!)"
    end

    def one_punch(pc, punches, employee, across_midnight, date)
      # we can't do anything with a single punch if we're across midnight
      return if across_midnight

      return PunchCard.recalculate(employee: employee, across_midnight: true, date: date) unless punches.first.in?
      # this is the only punch of the day, so we'll calculate the time from the punch to now -
      # and come back and do it again when the employee punches out'
      punches.update_all punch_card_id: pc.id
      work, ot1, ot2 = employee.divide_minutes((DateTime.current.to_i - punches.first.punched_at.to_i) / 60)
      pc.update work_minutes: work, ot1_minutes: ot1, ot2_minutes: ot2, break_minutes: 0
      say "Only one punch for #{employee.name} on #{date} - work_minutes set to #{pc.work_minutes}"
    end

    def two_punches(pc, punches, employee)
      punches.update_all punch_card_id: pc.id
      return unless punches.second.in?
      work, ot1, ot2 = employee.divide_minutes((punches.first.punched_at - punches.second.punched_at) / 60)
      pc.update work_minutes: work, ot1_minutes: ot1, ot2_minutes: ot2, break_minutes: 0
      say "Two punches for #{employee.name} on #{pc.work_date} - work_minutes set to #{pc.work_minutes}"
    end

    def more_punches(pc, punches, employee)
      begin
        punches.update_all punch_card_id: pc.id
        counters = { work: [], break: [] }
        stop = (pc.work_date == Date.current) ? DateTime.current.to_i : punches.first.punched_at.to_i
        punches.each_with_index do |punch, i|
          stint = ((stop - punch.punched_at.to_i)  / 60)
          if i == 0
            next if punch.out?
          end

          case punch.state
          when "break"; counters[:break] << stint
          when "in"; counters[:work] << stint
          end
          stop = punch.punched_at.to_i
        end
        work, ot1, ot2 = employee.divide_minutes counters[:work].sum
        pc.update work_minutes: work, ot1_minutes: ot1, ot2_minutes: ot2, break_minutes: counters[:break].sum
      rescue => e
        debugger
      end
    end
  end

  included do
  end
end
