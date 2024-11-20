class ProductsController < MortimerController
  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(product: [ :tenant_id, :erp_guid, :name, :product_number, :quantity, :unit, :account_number, :base_amount_value, :base_amount_value_incl_vat, :total_amount, :total_amount_incl_vat, :external_reference ])
    end
end
