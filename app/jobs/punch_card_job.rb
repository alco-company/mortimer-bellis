class PunchCardJob < ApplicationJob
  queue_as :default

  # args:
  #   account,
  #   employee:
  #   from_at:
  #   to_at:
  #
  def perform(**args)
    super(**args)
    employee = args[:employee]
    user_time_zone(employee.time_zone) do
      PunchCard.recalculate(**args)
    end
  end
end
