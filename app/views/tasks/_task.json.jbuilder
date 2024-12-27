json.extract! task, :id, :tenant_id, :title, :description, :state, :priority, :due_at, :completed_at, :ancestry, :project_id, :location_id, :progress, :archived, :created_at, :updated_at
json.url task_url(task, format: :json)
