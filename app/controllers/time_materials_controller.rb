class TimeMaterialsController < MortimerController
  def new
    super
    @resource.customer_name = TimeMaterial.by_exact_user(Current.user).last&.customer_name
    @resource.date = Time.current.to_date
    @resource.time = "0,25"
    @resource.user_id = Current.user.id
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:time_material).permit(:tenant_id, :date, :time, :about, :user_id, :customer_name, :customer_id, :project_name, :project_id, :product_name, :product_id, :quantity, :rate, :discount, :comment, :state, :is_invoice, :is_free, :is_offer, :is_separate)
    end
end
