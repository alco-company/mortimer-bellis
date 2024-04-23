class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Authentication
  include Resourceable
  include DefaultActions
  include TimezoneLocale

  # layout -> { ApplicationLayout }
end
