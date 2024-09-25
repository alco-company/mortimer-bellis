class PunchCardJob < ApplicationJob
  queue_as :default

  # args:
  #   tenant,
  #   user:
  #   from_at:
  #   to_at:
  #
  def perform(**args)
    super(**args)
    user = args[:user]
    user_time_zone(user.time_zone) do
      PunchCard.recalculate(**args)
    end
  end
end
