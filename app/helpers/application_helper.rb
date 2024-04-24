module ApplicationHelper
  include Pagy::Frontend

  def say(msg)
    Rails.logger.info '==============================='
    Rails.logger.info msg
    Rails.logger.info '==============================='
  end
end
