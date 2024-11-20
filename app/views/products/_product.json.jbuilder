json.extract! product, :id, :tenant_id, :erp_guid, :name, :product_number, :quantity, :unit, :account_number, :base_amount_value, :base_amount_value_incl_vat, :total_amount, :total_amount_incl_vat, :external_reference, :created_at, :updated_at
json.url product_url(product, format: :json)
