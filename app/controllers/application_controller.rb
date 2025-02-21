class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  #
  #
  protect_from_forgery with: :exception, prepend: true

  #
  #
  before_action :set_cache_buster

  #
  # rescue_from Exception, with: :handle_all_errors
  #

  #
  # will redirect_to root_path if a 404 is encountered
  #
  include ErrorHandling

  include PostHogging

  def say(msg)
    Rails.logger.info { "===============================" }
    Rails.logger.info { msg }
    Rails.logger.info { "===============================" }
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :otp_attempt ])
  end

  private

    #
    # very good description here: https://devcenter.heroku.com/articles/http-caching-ruby-rails
    # TODO - when should we bust the cache?
    #
    def set_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
end
