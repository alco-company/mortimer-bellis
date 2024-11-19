class LocationsController < MortimerController
  private
    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(location: [ :id, :tenant_id, :name, :color ])
    end
end
