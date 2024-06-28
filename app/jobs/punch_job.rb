class PunchJob < ApplicationJob
  queue_as :default

  attr_accessor :employee, :from_at, :to_at, :from_date, :from_time, :to_date, :to_time, :reason, :comment, :ip, :days, :excluded_days

  def perform(**args)
    super(**args)
    @employee = args[:employee]
    switch_locale(@employee.locale) do
      user_time_zone(@employee.time_zone) do
        calc_vars(args)
        its_today ? one_punch : range_punch
      end
    rescue => e
      say "(switch_locale) PunchJob failed: #{e.message}"
      false
    end
  end

  def calc_vars(args)
    @from_at = Time.parse("%sT%s" % [ args[:from_date], args[:from_time] ])
    @to_at = Time.parse("%sT%s" % [ args[:to_date], args[:to_time] ])
    @reason = args[:reason]
    @comment = args[:comment]
    @ip = args[:ip]
    @days = args[:days] || []
    @excluded_days = args[:excluded_days].split(/([\/\-\d]{2,11}|\d+\.\d+)[ ,;]?/).collect { |e| e if !e.blank? }.compact rescue []
  end

  def its_today
    (@from_at.to_date == @to_at.to_date) || (@to_at.hour < @from_at.hour)
  end

  def one_punch
    @from_at, @to_at = setTimeSlot(@employee, @reason, @from_at.to_datetime, @to_at.to_datetime, @from_at.to_datetime)
    punch_it!(@employee, @reason, @ip, @from_at.to_datetime, @to_at.to_datetime, @comment)
    Rails.env.local? ?
      PunchCardJob.perform_now(account: @employee.account, employee: @employee, date: @from_at) :
      PunchCardJob.perform_later(account: @employee.account, employee: @employee, date: @from_at)
  end

  def range_punch
    (@from_at.to_date..@to_at.to_date).each do |date|
      next unless @days.empty? || @days.include?(date.strftime("%A").downcase)
      next if excluded_days_include date, @excluded_days
      f_at, t_at = setTimeSlot(@employee, @reason, @from_at.to_datetime, @to_at.to_datetime, date.to_datetime)
      punch_it!(@employee, @reason, @ip, f_at, t_at, @comment)
    end
    Rails.env.local? ?
      PunchCardJob.perform_now(account: @employee.account, employee: @employee, from_at: @from_at.to_date, to_at: @to_at.to_date) :
      PunchCardJob.perform_later(account: @employee.account, employee: @employee, from_at: @from_at.to_date, to_at: @to_at.to_date)
  end

  def excluded_days_include(date, excluded_days)
    return false if excluded_days.empty?
    excluded_days.each do |ed|
      # 14-21/5 or 1/6-31/8
      eds = ed.split(/-/)
      eds = eds + eds if eds.count == 1
      eds.collect! { |d| build_date(d) }
      return true if date.between? eds[0], eds[1]
    end
    false
  end

  #
  # 14
  # 14/4
  # 14/4/24
  # 14/4/2024
  def build_date(d)
    de = d.split(/[\.\/]/)
    de += [ Date.today.month ] if de.count < 2
    de += [ Date.today.year ] if de.count < 3
    de[2] = de[2].to_i + 2000 if de[2].to_i < 100
    Date.new de[2].to_i, de[1].to_i, de[0].to_i
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
