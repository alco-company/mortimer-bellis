class TimeMaterialsController < MortimerController
  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:time_material).permit(:tenant_id, :date, :time, :about, :customer, :customer_id, :project, :project_id, :product, :product_id, :quantity, :rate, :discount, :is_invoice, :is_free, :is_offer, :is_separate)
    end
end
