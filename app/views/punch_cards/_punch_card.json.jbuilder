json.extract! punch_card, :id, :tenant_id, :employee_id, :work_date, :work_minutes, :ot1_minutes, :ot2_minutes, :break_minutes, :punches_settled_at, :created_at, :updated_at
json.url punch_card_url(punch_card, format: :json)
