class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  #
  #
  protect_from_forgery with: :exception

  #
  #
  before_action :set_cache_buster

  layout "application"
  # TODO - make Phlex layouts work
  # layout -> { ApplicationLayout }

  #
  # rescue_from Exception, with: :handle_all_errors
  #
  # This is essential to all controllers which is
  # why it gets included on the ApplicationController
  # and not the MortimerController - by inheriting
  # from the ApplicationController you may skip some of the
  # automagic - but authentication cannot be skipped; you can
  # override this, however, on controllers by calling
  # skip_before_action :authenticate_user!
  #
  include Authentication

  #
  # will redirect_to root_path if a 404 is encountered
  #
  include ErrorHandling

  #
  #
  #
  include Pagy::Backend
  #
  # the COUNT(*) can be avoided by implementing the following
  # method on the model
  def pagy_get_count(collection, vars)
    collection.respond_to?(:count_documents) ? collection.count_documents : super
  end

  def say(msg)
    Rails.logger.info "==============================="
    Rails.logger.info msg
    Rails.logger.info "==============================="
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
