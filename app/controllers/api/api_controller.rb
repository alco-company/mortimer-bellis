module Api
  class ApiController < ActionController::API
    # before_action :doorkeeper_authorize!
    # respond_to    :json

    # def current_resource_owner
    #   # User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    #   doorkeeper_token.application.owner if doorkeeper_token
    # end
    #
    # will redirect_to root_path if a 404 is encountered
    #
    # include ErrorHandling

    def say(msg)
      Rails.logger.info { "===============================" }
      Rails.logger.info { msg }
      Rails.logger.info { "===============================" }
    end
  end
end
