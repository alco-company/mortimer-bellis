json.extract! calendar, :id, :account_id, :calendarable_id, :calendarable_type, :name, :created_at, :updated_at
json.url calendar_url(calendar, format: :json)