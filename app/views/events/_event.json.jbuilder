json.extract! event, :id, :tenant_id, :calendar_id, :name, :from_date, :from_time, :to_date, :to_datetime, :duration, :all_day, :comment, :created_at, :updated_at
json.url event_url(event, format: :json)
