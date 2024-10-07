json.extract! customer, :id, :tenant_id, :name, :street, :zipcode, :city, :phone, :email, :vat_number, :ean_number, :created_at, :updated_at
json.url customer_url(customer, format: :json)
