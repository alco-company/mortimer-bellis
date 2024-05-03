class PunchCardJob < ApplicationJob
  queue_as :default

  # args: account, import_file
  #
  def perform(**args)
    super(**args)
    switch_locale do
      PunchCard.recalculate args[:employee]
    end
  end
end
