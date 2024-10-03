class SaasService
  #
  # services that inherit from this class should implement the following methods
  # auth_url - returns the url to redirect the user to in order to authorize the service
  # get_creds - persist third_party_service with token, more
  #
  def auth_url
    raise NotImplementedError
  end

  def get_creds(creds: {})
    raise NotImplementedError
  end

  #
  # arguments:
  # name - name of the service, eg "Dinero" - should be "translatable" to a class name
  # service_params - hash of params to be persisted in the database, eg { access_token: "", refresh_token: "", expires_in: 0 }
  #
  def add_service(name, service_params)
    ps = ProvidedService.find_by(tenant: Current.tenant, service: self.class.to_s, name: name)
    ps.nil? ? create_service(name, service_params) : update_service(ps, service_params)
  end

  private
    def create_service(name, service_params)
      ProvidedService.create(tenant: Current.tenant, authorized_by: Current.user, name: name, service: self.class.to_s, service_params: service_params)
    end

    def update_service(ps, service_params)
      ps.update(service_params: service_params, authorized_by: Current.user)
    end
end
