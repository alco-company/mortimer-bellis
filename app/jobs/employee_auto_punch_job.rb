class EmployeeAutoPunchJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    date=DateTime.current
    User.by_tenant.each do |user|
      next if user.did_punch(date)
      user.punch_by_calendar(date)
      # next if user.get_contract_days_per_week < 6 and (DateTime.current.saturday? or DateTime.current.sunday?)
      # next if user.get_contract_days_per_week < 7 and (DateTime.current.sunday?)
      # next if user.todays_punches.any?
      # mins = user.get_contract_minutes_per_day
      # user.punch_range :in, "server", (DateTime.current.beginning_of_day + 8.hours), (DateTime.current.beginning_of_day + 8.hours + mins.minutes)
    end
    # Do something later
    true
  end
end
