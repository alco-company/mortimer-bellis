class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  include Authentication
  include Pagy::Backend

  layout "application"
  # TODO - make Phlex layouts work
  # layout -> { ApplicationLayout }

  def say(msg)
    Rails.logger.info "==============================="
    Rails.logger.info msg
    Rails.logger.info "==============================="
  end
end
