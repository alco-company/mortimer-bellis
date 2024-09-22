json.extract! punch, :id, :tenant_id, :employee_id, :punch_clock, :punched_at, :state, :remote_ip, :created_at, :updated_at
json.url punch_url(punch, format: :json)
