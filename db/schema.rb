# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_10_07_113648) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "background_jobs", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.integer "user_id"
    t.integer "state", default: 0
    t.string "job_klass"
    t.text "params"
    t.text "schedule"
    t.datetime "next_run_at"
    t.string "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_background_jobs_on_tenant_id"
    t.index ["user_id"], name: "index_background_jobs_on_user_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "calendarable_type", null: false
    t.integer "calendarable_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendarable_type", "calendarable_id"], name: "index_calendars_on_calendarable"
    t.index ["tenant_id"], name: "index_calendars_on_tenant_id"
  end

  create_table "customers", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "erp_guid"
    t.string "name"
    t.string "street"
    t.string "zipcode"
    t.string "city"
    t.string "phone"
    t.string "email"
    t.string "vat_number"
    t.string "ean_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_customers_on_tenant_id"
  end

  create_table "dashboards", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "feed"
    t.text "last_feed"
    t.datetime "last_feed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_dashboards_on_tenant_id"
  end

  create_table "event_meta", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "days"
    t.string "weeks"
    t.string "weekdays"
    t.string "months"
    t.string "years"
    t.text "rrule"
    t.text "ice_cube"
    t.text "ui_values"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_meta_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.integer "calendar_id", null: false
    t.string "name"
    t.date "from_date"
    t.datetime "from_time"
    t.date "to_date"
    t.datetime "to_time"
    t.integer "duration"
    t.boolean "auto_punch"
    t.boolean "all_day"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "work_type"
    t.string "reason"
    t.integer "break_minutes"
    t.boolean "breaks_included"
    t.string "color"
    t.index ["calendar_id"], name: "index_events_on_calendar_id"
    t.index ["tenant_id"], name: "index_events_on_tenant_id"
  end

  create_table "filters", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "view"
    t.json "filter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_filters_on_tenant_id"
  end

  create_table "holidays", force: :cascade do |t|
    t.string "name"
    t.string "countries"
    t.date "from_date"
    t.date "to_date"
    t.integer "all_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_locations_on_tenant_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.string "type"
    t.string "record_type"
    t.bigint "record_id"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notifications_count"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.string "type"
    t.bigint "event_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "pages", force: :cascade do |t|
    t.string "slug"
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provided_services", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.integer "authorized_by_id", null: false
    t.string "name"
    t.string "service"
    t.text "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorized_by_id"], name: "index_provided_services_on_authorized_by_id"
    t.index ["tenant_id"], name: "index_provided_services_on_tenant_id"
  end

  create_table "punch_cards", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.integer "user_id", null: false
    t.date "work_date"
    t.integer "work_minutes"
    t.integer "ot1_minutes"
    t.integer "ot2_minutes"
    t.integer "break_minutes"
    t.datetime "punches_settled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_punch_cards_on_tenant_id"
    t.index ["user_id"], name: "index_punch_cards_on_user_id"
  end

  create_table "punch_clocks", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.integer "location_id", null: false
    t.string "name"
    t.string "ip_addr"
    t.datetime "last_punched_at"
    t.string "access_token"
    t.string "locale"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_punch_clocks_on_location_id"
    t.index ["tenant_id"], name: "index_punch_clocks_on_tenant_id"
  end

  create_table "punches", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.integer "user_id", null: false
    t.bigint "punch_clock_id"
    t.datetime "punched_at"
    t.integer "state", default: 0
    t.string "remote_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "punch_card_id"
    t.string "comment"
    t.index ["tenant_id"], name: "index_punches_on_tenant_id"
    t.index ["user_id"], name: "index_punches_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "setable_type"
    t.integer "setable_id"
    t.string "key"
    t.integer "priority"
    t.string "format"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["setable_type", "setable_id"], name: "index_settings_on_setable"
    t.index ["tenant_id"], name: "index_settings_on_tenant_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "name"
    t.string "color"
    t.string "locale"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "punches_settled_at"
    t.string "payroll_team_ident"
    t.integer "state", default: 0
    t.text "description"
    t.string "email"
    t.string "cell_phone"
    t.string "pbx_extension"
    t.integer "contract_minutes"
    t.integer "contract_days_per_payroll"
    t.integer "contract_days_per_week"
    t.string "hour_pay"
    t.string "ot1_add_hour_pay"
    t.string "ot2_add_hour_pay"
    t.integer "hour_rate_cent", default: 0
    t.integer "ot1_hour_add_cent", default: 0
    t.integer "ot2_hour_add_cent", default: 0
    t.datetime "tmp_overtime_allowed"
    t.string "eu_state"
    t.boolean "blocked"
    t.integer "allowed_ot_minutes"
    t.string "country"
    t.index ["tenant_id"], name: "index_teams_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "pp_identification"
    t.string "locale"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "send_state_rrule"
    t.string "send_eu_state_rrule"
    t.string "color"
    t.string "tax_number"
    t.string "country"
    t.string "access_token"
  end

  create_table "users", force: :cascade do |t|
    t.integer "tenant_id", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "role", default: 0
    t.string "locale", default: "en"
    t.string "time_zone", default: "UTC"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "name"
    t.boolean "global_queries", default: false
    t.datetime "locked_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.integer "team_id", default: 1, null: false
    t.integer "state", default: 0
    t.integer "eu_state", default: 0
    t.string "color"
    t.string "pincode"
    t.string "pos_token"
    t.string "job_title"
    t.datetime "hired_at"
    t.datetime "birthday"
    t.datetime "last_punched_at"
    t.string "cell_phone"
    t.boolean "blocked_from_punching", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "background_jobs", "tenants"
  add_foreign_key "background_jobs", "tenants", on_delete: :cascade
  add_foreign_key "calendars", "tenants"
  add_foreign_key "customers", "tenants"
  add_foreign_key "dashboards", "tenants"
  add_foreign_key "dashboards", "tenants", on_delete: :cascade
  add_foreign_key "event_meta", "events"
  add_foreign_key "events", "calendars"
  add_foreign_key "events", "tenants"
  add_foreign_key "filters", "tenants"
  add_foreign_key "filters", "tenants"
  add_foreign_key "filters", "tenants"
  add_foreign_key "filters", "tenants", on_delete: :cascade
  add_foreign_key "locations", "tenants", on_delete: :cascade
  add_foreign_key "provided_services", "tenants"
  add_foreign_key "provided_services", "users", column: "authorized_by_id"
  add_foreign_key "punch_cards", "tenants"
  add_foreign_key "punch_cards", "tenants", on_delete: :cascade
  add_foreign_key "punch_clocks", "locations", on_delete: :cascade
  add_foreign_key "punch_clocks", "tenants", on_delete: :cascade
  add_foreign_key "punches", "punch_cards", on_delete: :cascade
  add_foreign_key "punches", "tenants"
  add_foreign_key "punches", "tenants", on_delete: :cascade
  add_foreign_key "settings", "tenants"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "teams", "tenants"
  add_foreign_key "teams", "tenants", on_delete: :cascade
  add_foreign_key "users", "teams"
  add_foreign_key "users", "teams", on_delete: :cascade
  add_foreign_key "users", "tenants"
  add_foreign_key "users", "tenants", on_delete: :cascade
  add_foreign_key "users", "tenants", on_delete: :cascade
end
