json.extract! project, :id, :name, :tenant_id, :customer_id, :description, :start_date, :end_date, :state, :budget, :is_billable, :hourly_rate, :priority, :estimated_minutes, :actual_minutes, :created_at, :updated_at
json.url project_url(project, format: :json)
