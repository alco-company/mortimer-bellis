class Oauth::ApplicationsController < MortimerController
    # Only allow a list of trusted parameters through.

    def create_callback
      @resource.update owner: Current.user
    end

    def update_callback
      @resource.update owner: Current.user
    end

    def resource_params
      params.expect(oauth_application: [ :id, :name, :uid, :confidential, :redirect_uri, :scopes ])
    end
end
