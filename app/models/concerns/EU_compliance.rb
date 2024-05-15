module EUCompliance
  extend ActiveSupport::Concern

  included do
    # a limit to weekly working hours
    #   - the average working time for each seven day period must not exceed 48 hours, including overtime
    #   - depending on national legislation and/or collective agreements, the 48 hour average is calculated over a reference period of up to 4, 6 or 12 months
    def max_48_hrs_per_7_days
      last_7_days.sum(:work_minutes) < (8*60)
    end

    # a rest break during working hours
    # if the worker is on duty for longer than 6 hours
    def min_6_hrs_rest_break
      (work_yesterday.works < 6*60) or (work_yesterday.breaks > 0)
    rescue
      debugger
    end

    # a minimum daily rest period
    # in every 24 hours a worker is entitled to a minimum of 11 consecutive hours of rest
    def min_11_hrs_rest
      last_2_days.count < 2 or ((last_2_days.first.first_punch.to_i - last_2_days.last.last_punch.to_i) > 11 * 60)
    end

    # a minimum weekly rest period
    # for each 7-day period a worker is entitled to a minimum of 24 uninterrupted hours in addition to the 11 hours' daily rest
    def min_24_hrs_rest_weekly
      wd = {}
      last_7_days.each { |p| wd[p.work_date.strftime("%Y-%m-%d")] = p.works }
      ((Date.yesterday - 7.days)..Date.yesterday).each do |date|
        return true unless wd.keys.include? date.strftime("%Y-%m-%d")
      end
      false
    end

    # extra protection in case of night work
    # average working hours must not exceed 8 hours per 24-hour period,
    def max_8_hrs_night
      last_2_days.count < 2 or (last_2_days.last.first_punch.hour < 22) or ((last_2_days.first.first_punch.to_i - last_2_days.last.last_punch.to_i) < (8 * 60 +1))
    end

    def work_yesterday
      punch_cards.where(work_date: Date.yesterday).first || PunchCard.new(employee: employee, work_minutes: 0, break_minnutes: 0)
    rescue
      PunchCard.new employee: self, work_minutes: 0, break_minutes: 0
    end

    def last_2_days
      punch_cards.where(work_date: (Date.yesterday - 1.day)..(Date.yesterday)).order(work_date: :desc)
    end

    def last_7_days
      punch_cards.where(work_date: (Date.yesterday - 7.day)..(Date.yesterday))
    end
  end

  class_methods do
  end
end
