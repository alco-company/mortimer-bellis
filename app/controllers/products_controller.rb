class ProductsController < MortimerController
  #
  def update
    params[:product][:base_amount_value] = resource_params[:base_amount_value].split(" ").last.gsub(",", ".") rescue 0
    super
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(product: [ :tenant_id, :erp_guid, :name, :product_number, :quantity, :unit, :account_number, :base_amount_value, :base_amount_value_incl_vat, :total_amount, :total_amount_incl_vat, :external_reference ])
    end
end
