json.extract! time_material, :id, :tenant_id, :date, :time, :about, :customer, :customer_id, :project, :project_id, :product, :product_id, :quantity, :rate, :discount, :is_invoice, :is_free, :is_offer, :is_separate, :created_at, :updated_at
json.url time_material_url(time_material, format: :json)
