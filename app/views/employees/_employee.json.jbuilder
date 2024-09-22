json.extract! employee, :id, :tenant_id, :team_id, :name, :pincode, :payroll_employee_ident, :access_token, :last_punched_at, :state, :created_at, :updated_at
json.url employee_url(employee, format: :json)
