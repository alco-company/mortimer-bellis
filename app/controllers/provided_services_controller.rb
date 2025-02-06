class ProvidedServicesController < MortimerController
  def new
    if params[:service].present?
      case params[:service]&.downcase
      when "dinero"; set_dinero
      end
    end
  end
  private

    def set_dinero
      @resource.name = "Dinero"
      @resource.service = "Dinero::Service"
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params[:provided_service][:authorized_by_id] = Current.user.id
      params.expect(provided_service: [ :tenant_id, :authorized_by_id, :name, :service, :service_params, :organizationID, :account_for_one_off, :product_for_time, :product_for_overtime, :product_for_overtime_100, :product_for_mileage, :product_for_hardware ])
    end
end
