class InvoiceItemsController < MortimerController
  private
    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(invoice_item: [ :tenant_id, :invoice_id, :project_id, :product_id, :product_guid, :description, :comments, :quantity, :account_number, :unit, :discount, :line_type, :base_amount_value, :base_amount_value_incl_vat, :total_amount, :total_amount_incl_vat ])
    end
end
