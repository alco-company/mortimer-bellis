json.extract! team, :id, :tenant_id, :name, :team_color, :locale, :time_zone, :created_at, :updated_at
json.url team_url(team, format: :json)
