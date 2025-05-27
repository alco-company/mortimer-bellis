class ProvidedServicesController < MortimerController
  def new
    if params[:service].present?
      case params[:service]&.downcase
      when /inero$/; set_dinero
      end
    end
  end
  private

    def set_dinero
      @resource.name = "Dinero"
      @resource.service = "Dinero::Service"
      @resource.account_for_one_off = "1000"
      @resource.product_for_time = "Time"
      @resource.product_for_overtime = "Time50"
      @resource.product_for_overtime_100 = "Time100"
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params[:provided_service][:authorized_by_id] = Current.user.id
      params.expect(provided_service: [ :tenant_id, :authorized_by_id, :name, :service, :service_params, :organizationID, :account_for_one_off, :product_for_time, :product_for_overtime, :product_for_overtime_100, :product_for_mileage, :product_for_hardware ])
    end

    def create_callback
      return true unless @resource&.name.downcase =~ /^dinero/
      BackgroundJob.create tenant_id: Current.tenant.id, user_id: Current.user.id, job_klass: "RefreshErpTokenJob", state: :un_planned, schedule: "1 */3 * * *", params: ""
    end
end
