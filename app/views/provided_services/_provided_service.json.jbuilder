json.extract! provided_service, :id, :tenant_id, :authorized_by_id, :name, :service, :params, :created_at, :updated_at
json.url provided_service_url(provided_service, format: :json)
