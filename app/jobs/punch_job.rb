class PunchJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    employee = args[:employee]
    switch_locale(employee.locale) do
      user_time_zone(employee.time_zone) do
        from_at = Time.zone.parse args[:from_at]
        to_at = Time.zone.parse args[:to_at]
        reason = args[:reason]
        comment = args[:comment]
        ip = args[:ip]
        days = args[:days]
        begin
          if (from_at.to_date == to_at.to_date) || (to_at.hour < from_at.hour)
            from_at, to_at = setTimeSlot(employee, reason, from_at.to_datetime, to_at.to_datetime, from_at.to_datetime)
            punch_it!(employee, reason, ip, from_at.to_datetime, to_at.to_datetime, comment)
            PunchCardJob.new.perform(account: employee.account, employee: employee, date: from_at)
          else
            (from_at.to_date..to_at.to_date).each do |date|
              next unless days.empty? || days.include?(date.strftime("%A").downcase)
              f_at, t_at = setTimeSlot(employee, reason, from_at.to_datetime, to_at.to_datetime, date.to_datetime)
              punch_it!(employee, reason, ip, f_at, t_at, comment)
            end
            PunchCardJob.new.perform(account: employee.account, employee: employee, from_at: from_at.to_date, to_at: to_at.to_date)
          end
        rescue => e
          say "PunchJob failed: #{e.message}"
        end
      end
    rescue => e
      say "(switch_locale) PunchJob failed: #{e.message}"
      false
    end
  end

  def punch_it!(employee, reason, ip, from_at, to_at, comment = nil)
    punch_clock = PunchClock.by_account(employee.account).first
    Punch.create! account: employee.account, employee: employee, punch_clock: punch_clock, punched_at: from_at, state: reason, remote_ip: ip, comment: comment
    Punch.create! account: employee.account, employee: employee, punch_clock: punch_clock, punched_at: to_at, state: :out, remote_ip: ip, comment: comment
  end

  def setTimeSlot(employee, reason, from_at, to_at, date)
    if reason =~ /sick/
      [ (date.beginning_of_day + 7.hours), date.beginning_of_day + 7.hours + employee.get_contract_minutes_per_day.minutes ]
    else
      fhour = from_at.hour
      minute = from_at.min
      from_at = date.beginning_of_day + fhour.hours + minute.minutes

      thour = to_at.hour
      minute = to_at.min
      date = to_at.to_date if thour < fhour
      to_at = date.beginning_of_day + thour.hours + minute.minutes
      [ from_at, to_at ]
    end
  rescue
    say "Failed to parse time slot #{from_at} - or calculate end time for #{ self.inspect }"
    [ date.beginning_of_day, date.beginning_of_day + 7.hours + 40.minutes ]
  end
end
