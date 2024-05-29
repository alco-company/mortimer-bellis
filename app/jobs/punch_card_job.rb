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
    switch_locale do
      PunchCard.recalculate(**args)
    end
  end
end
