class TenantsController < MortimerController
  before_action :authorize, only: [ :create, :update, :destroy ]
  before_action :resize_logo, only: [ :create, :update ]

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

    def resize_logo
      return unless params[:tenant][:logo].present?
      resize_before_save(params[:tenant][:logo], 80, 40)
    end

    def create_callback(resource)
      params[:tenant].delete(:logo)
      TenantRegistrationService.call(resource)
      # TenantUser.create(tenant_id: resource.id, user_id: Current.user.id, role: "superadmin")
    end

    def update_callback(_u)
      params[:tenant].delete(:logo)
    end
end
