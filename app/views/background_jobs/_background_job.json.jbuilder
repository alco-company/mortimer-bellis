json.extract! background_job, :id, :account_id, :user_id, :state, :job_klass, :params, :schedule, :next_run_at, :job_id, :created_at, :updated_at
json.url background_job_url(background_job, format: :json)
