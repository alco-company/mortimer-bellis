class LocationsController < MortimerController
  private
    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:location).permit(:id, :tenant_id, :name, :location_color)
    end
end
