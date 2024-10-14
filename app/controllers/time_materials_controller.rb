class TimeMaterialsController < MortimerController
  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:time_material).permit(:tenant_id, :date, :time, :about, :customer_name, :customer_id, :project_name, :project_id, :product_name, :product_id, :quantity, :rate, :discount, :state, :is_invoice, :is_free, :is_offer, :is_separate)
    end
end
