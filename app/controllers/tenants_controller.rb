class TenantsController < MortimerController
  before_action :authorize, only: [ :create, :update, :destroy ]

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:tenant).permit(:id, :name, :country, :color, :email, :tax_number, :logo, :pp_identification, :locale, :time_zone)
    end

    def authorize
      return if current_user.superadmin?
      redirect_to root_path, alert: t(:unauthorized) and return if current_user.user?
      redirect_to root_path, alert: t(:unauthorized) and return if params["action"] == "index"
      redirect_to root_path, alert: t(:unauthorized) and return unless params["id"] == Current.tenant.id.to_s
    end

    def create_callback(resource)
      TenantRegistrationService.call(resource)
      # TenantUser.create(tenant_id: resource.id, user_id: Current.user.id, role: "superadmin")
    end
end
