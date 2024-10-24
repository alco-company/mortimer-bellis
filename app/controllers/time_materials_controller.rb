class TimeMaterialsController < MortimerController
  def new
    super
    @resource.customer_name = TimeMaterial.by_exact_user(Current.user).last&.customer_name
    @resource.date = Time.current.to_date
    @resource.time = "0,25"
    @resource.user_id = Current.user.id
  end

  def edit
    @resource.customer_name = @resource.customer&.name unless @resource.customer_id.blank?
    @resource.project_name = @resource.project&.name unless @resource.project_id.blank?
    @resource.product_name = @resource.product&.name unless @resource.product_id.blank?
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:time_material).permit(
        :tenant_id,
        :date,
        :time,
        :overtime,
        :about,
        :user_id,
        :customer_name,
        :customer_id,
        :project_name,
        :project_id,
        :product_name,
        :product_id,
        :quantity,
        :rate,
        :unit_price,
        :unit,
        :discount,
        :comment,
        :state,
        :is_invoice,
        :is_free,
        :is_offer,
        :is_separate
      )
    end
end
