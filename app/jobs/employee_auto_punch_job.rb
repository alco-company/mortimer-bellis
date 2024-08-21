class EmployeeAutoPunchJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    date=DateTime.current
    Employee.by_account.each do |employee|
      next if employee.did_punch(date)
      employee.punch_by_calendar(date)
      # next if employee.get_contract_days_per_week < 6 and (DateTime.current.saturday? or DateTime.current.sunday?)
      # next if employee.get_contract_days_per_week < 7 and (DateTime.current.sunday?)
      # next if employee.todays_punches.any?
      # mins = employee.get_contract_minutes_per_day
      # employee.punch_range :in, "server", (DateTime.current.beginning_of_day + 8.hours), (DateTime.current.beginning_of_day + 8.hours + mins.minutes)
    end
    # Do something later
    true
  end
end
