json.extract! tenant, :id, :name, :email, :pp_identification, :locale, :time_zone, :created_at, :updated_at
json.url tenant_url(tenant, format: :json)
