module ErrorHandling
  extend ActiveSupport::Concern

  included do
    add_flash_types :info, :success, :error, :warning

    #
    # You want to get exceptions in development, but not in production.
    unless Rails.application.config.consider_all_requests_local
      rescue_from ActionController::RoutingError, with: -> { render_404  }
      # rescue_from ActionController::UnknownController, with: -> { render_404  }
      rescue_from ActionController::UnknownFormat, with: -> { render_404  }
      rescue_from ActiveRecord::RecordNotFound,        with: -> { render_404 }
      rescue_from ActionController::UrlGenerationError, with: -> { render_404 }
    end
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_bad_csrf_token

    # def blackholed
    #   render_404
    # end

    def render_404
      respond_to do |format|
        # format.html { render template: 'errors/not_found', status: 404 }
        # format.all { render nothing: true, status: 404 }
        # format.all { head :ok }
        format.all { render_not_found  }
      end
    end

    def render_40x
      respond_to do |format|
        # format.html { render template: 'errors/not_found', status: 404 }
        # format.all { render nothing: true, status: 404 }
        # format.all { head :ok }
        format.all { redirect_to root_path, warning: t("old_csrf")  }
      end
    end

    def render_not_found
      # flash[:warning] = flash.now[:warning] = t("page_not_found")
      redirect_to root_path, warning: t("page_not_found")
      # render turbo_stream: turbo_stream.replace( "flash", partial: 'shared/notifications' ), status: 404
    end

    #
    # find route in routes.rb - not active as of yet
    # TODO - make the blackholed route active
    def blackholed
      # `sudo route add #{request.remote_ip} gw 127.0.0.1 lo`
      head :ok
    end

    def handle_bad_csrf_token
      url = request.path == "/session" ? new_users_session_url : root_url
      logger.error("Invalid CSRF token")
      redirect_back(fallback_location: url, alert: "Your session has expired. Please try again.")
    end
  end
end
