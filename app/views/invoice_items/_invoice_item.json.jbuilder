json.extract! invoice_item, :id, :tenant_id, :invoice_id, :project_id, :product_id, :product_guid, :description, :comments, :quantity, :account_number, :unit, :discount, :line_type, :base_amount_value, :base_amount_value_incl_vat, :total_amount, :total_amount_incl_vat, :created_at, :updated_at
json.url invoice_item_url(invoice_item, format: :json)
