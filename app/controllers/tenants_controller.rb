class TenantsController < MortimerController
  before_action :authorize # , only: [ :create, :update, :destroy ]
  before_action :resize_logo, only: [ :create, :update ]

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(tenant: [ :id, :name, :country, :color, :email, :tax_number, :logo, :pp_identification, :locale, :time_zone, :license, :license_expires_at, :license_changed_at ])
    end

    #
    # called from authorize concern
    def authorize_controller
      params["id"] == Current.get_tenant.id.to_s
    end

    def resize_logo
      return unless params[:tenant][:logo].present?
      resize_before_save(params[:tenant][:logo], 80, 40)
    end

    def create_callback
      params[:tenant].delete(:logo)
      TenantRegistrationService.call(@resource)
      true
      # TenantUser.create(tenant_id: resource.id, user_id: Current.user.id, role: "superadmin")
    end

    def update_callback
      params[:tenant].delete(:logo)
      true
    rescue
      false
    end
end
