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

ActiveRecord::Schema[8.2].define(version: 2025_12_16_083809) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "background_jobs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "job_id"
    t.string "job_klass"
    t.text "job_progress"
    t.datetime "next_run_at"
    t.text "params"
    t.text "schedule"
    t.integer "state", default: 0
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["tenant_id"], name: "index_background_jobs_on_tenant_id"
    t.index ["user_id"], name: "index_background_jobs_on_user_id"
  end

  create_table "batches", force: :cascade do |t|
    t.boolean "all"
    t.datetime "created_at", null: false
    t.string "entity"
    t.text "ids"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["tenant_id"], name: "index_batches_on_tenant_id"
    t.index ["user_id"], name: "index_batches_on_user_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.integer "calendarable_id", null: false
    t.string "calendarable_type", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["calendarable_type", "calendarable_id"], name: "index_calendars_on_calendarable"
    t.index ["tenant_id"], name: "index_calendars_on_tenant_id"
  end

  create_table "calls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "direction"
    t.string "phone"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_calls_on_tenant_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "att_person"
    t.string "city"
    t.string "company_status"
    t.string "country_key"
    t.datetime "created_at", null: false
    t.string "ean_number"
    t.string "email"
    t.string "erp_guid"
    t.string "external_reference"
    t.decimal "hourly_rate", precision: 11, scale: 2, default: "0.0", null: false
    t.string "invoice_mail_out_option_key"
    t.boolean "is_creditor"
    t.boolean "is_debitor"
    t.boolean "is_member"
    t.boolean "is_person"
    t.string "member_number"
    t.string "name"
    t.string "payment_condition_number_of_days"
    t.string "payment_condition_type"
    t.string "phone"
    t.string "street"
    t.integer "tenant_id", null: false
    t.text "transmit_log"
    t.datetime "updated_at", null: false
    t.string "vat_number"
    t.string "vat_region_key"
    t.string "webpage"
    t.string "zipcode"
    t.index ["tenant_id"], name: "index_customers_on_tenant_id"
  end

  create_table "dashboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "feed"
    t.text "last_feed"
    t.datetime "last_feed_at"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_dashboards_on_tenant_id"
  end

  create_table "editor_blocks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.integer "document_id", null: false
    t.integer "parent_id"
    t.integer "position"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_editor_blocks_on_document_id"
  end

  create_table "editor_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "tenant_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_editor_documents_on_tenant_id"
  end

  create_table "event_meta", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "days"
    t.integer "event_id", null: false
    t.text "ice_cube"
    t.string "months"
    t.text "rrule"
    t.text "ui_values"
    t.datetime "updated_at", null: false
    t.string "weekdays"
    t.string "weeks"
    t.string "years"
    t.index ["event_id"], name: "index_event_meta_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "all_day"
    t.boolean "auto_punch"
    t.integer "break_minutes"
    t.boolean "breaks_included"
    t.integer "calendar_id", null: false
    t.string "color"
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "duration"
    t.date "from_date"
    t.datetime "from_time"
    t.string "name"
    t.string "reason"
    t.integer "tenant_id", null: false
    t.date "to_date"
    t.datetime "to_time"
    t.datetime "updated_at", null: false
    t.string "work_type"
    t.index ["calendar_id"], name: "index_events_on_calendar_id"
    t.index ["tenant_id"], name: "index_events_on_tenant_id"
  end

  create_table "filters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "filter"
    t.string "name"
    t.integer "state", default: 0
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "view"
    t.index ["tenant_id"], name: "index_filters_on_tenant_id"
  end

  create_table "holidays", force: :cascade do |t|
    t.integer "all_day"
    t.string "countries"
    t.datetime "created_at", null: false
    t.date "from_date"
    t.string "name"
    t.date "to_date"
    t.datetime "updated_at", null: false
  end

  create_table "invoice_items", force: :cascade do |t|
    t.string "account_number"
    t.decimal "base_amount_value"
    t.decimal "base_amount_value_incl_vat"
    t.text "comments"
    t.datetime "created_at", null: false
    t.string "description"
    t.decimal "discount"
    t.integer "invoice_id", null: false
    t.string "line_type"
    t.string "product_guid"
    t.integer "product_id", null: false
    t.integer "project_id"
    t.decimal "quantity"
    t.integer "tenant_id", null: false
    t.decimal "total_amount"
    t.decimal "total_amount_incl_vat"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
    t.index ["product_id"], name: "index_invoice_items_on_product_id"
    t.index ["tenant_id"], name: "index_invoice_items_on_tenant_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.string "address"
    t.text "comment"
    t.string "contact_guid"
    t.datetime "created_at", null: false
    t.string "currency"
    t.integer "customer_id", null: false
    t.string "description"
    t.string "erp_guid"
    t.string "external_reference"
    t.datetime "invoice_date"
    t.string "invoice_number"
    t.string "invoice_template_id"
    t.boolean "is_mobile_pay_invoice_enabled"
    t.boolean "is_penso_pay_enabled"
    t.string "latest_mail_out_type"
    t.string "locale"
    t.integer "mail_out_state"
    t.integer "payment_condition_number_of_days"
    t.string "payment_condition_type"
    t.datetime "payment_date"
    t.integer "project_id"
    t.decimal "reminder_fee", precision: 10, scale: 2
    t.decimal "reminder_interest_rate", precision: 10, scale: 2
    t.boolean "show_lines_incl_vat"
    t.integer "state"
    t.integer "tenant_id", null: false
    t.decimal "total_excl_vat", precision: 10, scale: 2
    t.decimal "total_excl_vat_in_dkk", precision: 10, scale: 2
    t.decimal "total_incl_vat", precision: 10, scale: 2
    t.decimal "total_incl_vat_in_dkk", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["tenant_id"], name: "index_invoices_on_tenant_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_locations_on_tenant_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.json "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "noticed_web_push_subs", force: :cascade do |t|
    t.string "auth_key", null: false
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.string "p256dh_key", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "user_type", null: false
    t.index ["user_type", "user_id"], name: "index_noticed_web_push_subs_on_user"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "application_id", null: false
    t.datetime "created_at", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.integer "resource_owner_id", null: false
    t.datetime "revoked_at"
    t.string "scopes", default: "", null: false
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "application_id", null: false
    t.datetime "created_at", null: false
    t.integer "expires_in"
    t.string "previous_refresh_token", default: "", null: false
    t.string "refresh_token"
    t.integer "resource_owner_id"
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "owner_id"
    t.string "owner_type"
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "pages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "slug"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer "account_number"
    t.decimal "base_amount_value", precision: 11, scale: 2
    t.decimal "base_amount_value_incl_vat", precision: 11, scale: 2
    t.datetime "created_at", null: false
    t.string "erp_guid"
    t.string "external_reference"
    t.string "name"
    t.string "product_number"
    t.decimal "quantity", precision: 9, scale: 3
    t.integer "tenant_id", null: false
    t.decimal "total_amount", precision: 11, scale: 2
    t.decimal "total_amount_incl_vat", precision: 11, scale: 2
    t.text "transmit_log"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_products_on_tenant_id"
  end

  create_table "projects", force: :cascade do |t|
    t.integer "actual_minutes"
    t.decimal "budget", precision: 11, scale: 2
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.text "description"
    t.datetime "end_date"
    t.integer "estimated_minutes"
    t.decimal "hourly_rate", precision: 11, scale: 2
    t.boolean "is_billable"
    t.boolean "is_separate_invoice"
    t.string "name"
    t.integer "priority"
    t.datetime "start_date"
    t.integer "state"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_projects_on_customer_id"
    t.index ["tenant_id"], name: "index_projects_on_tenant_id"
  end

  create_table "provided_services", force: :cascade do |t|
    t.string "account_for_one_off"
    t.integer "authorized_by_id"
    t.datetime "created_at", null: false
    t.datetime "last_sync_at"
    t.text "last_sync_status"
    t.string "name"
    t.string "organizationID"
    t.text "params"
    t.string "product_for_hardware"
    t.string "product_for_mileage"
    t.string "product_for_overtime"
    t.string "product_for_overtime_100"
    t.string "product_for_time"
    t.string "service"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["authorized_by_id"], name: "index_provided_services_on_authorized_by_id"
    t.index ["tenant_id"], name: "index_provided_services_on_tenant_id"
  end

  create_table "punch_cards", force: :cascade do |t|
    t.integer "break_minutes"
    t.datetime "created_at", null: false
    t.integer "ot1_minutes"
    t.integer "ot2_minutes"
    t.datetime "punches_settled_at"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.date "work_date"
    t.integer "work_minutes"
    t.index ["tenant_id"], name: "index_punch_cards_on_tenant_id"
    t.index ["user_id"], name: "index_punch_cards_on_user_id"
  end

  create_table "punch_clocks", force: :cascade do |t|
    t.string "access_token"
    t.datetime "created_at", null: false
    t.string "ip_addr"
    t.datetime "last_punched_at"
    t.string "locale"
    t.integer "location_id", null: false
    t.string "name"
    t.integer "tenant_id", null: false
    t.string "time_zone"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_punch_clocks_on_location_id"
    t.index ["tenant_id"], name: "index_punch_clocks_on_tenant_id"
  end

  create_table "punches", force: :cascade do |t|
    t.string "comment"
    t.datetime "created_at", null: false
    t.integer "punch_card_id"
    t.bigint "punch_clock_id"
    t.datetime "punched_at"
    t.string "remote_ip"
    t.integer "state", default: 0
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["tenant_id"], name: "index_punches_on_tenant_id"
    t.index ["user_id"], name: "index_punches_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "authentication_strategy", default: 0
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.boolean "otp_passed", default: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "formating"
    t.string "key"
    t.integer "priority"
    t.integer "setable_id"
    t.string "setable_type"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["setable_type", "setable_id"], name: "index_settings_on_setable"
    t.index ["tenant_id"], name: "index_settings_on_tenant_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.integer "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.string "context"
    t.datetime "created_at", null: false
    t.integer "tag_id", null: false
    t.integer "taggable_id", null: false
    t.string "taggable_type", null: false
    t.integer "user_id", null: false
    t.index ["tag_id", "taggable_id", "taggable_type", "context"], name: "idx_on_tag_id_taggable_id_taggable_type_context_c1f328cb83", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
    t.index ["user_id"], name: "index_taggings_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "category"
    t.string "context"
    t.integer "count", default: 0
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["tenant_id", "category", "name"], name: "index_tags_on_tenant_id_and_category_and_name", unique: true
    t.index ["tenant_id", "context", "name"], name: "index_tags_on_tenant_id_and_context_and_name", unique: true
    t.index ["tenant_id"], name: "index_tags_on_tenant_id"
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.boolean "archived"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "customer_id"
    t.text "description"
    t.datetime "due_at"
    t.string "link"
    t.integer "priority"
    t.integer "progress"
    t.integer "project_id"
    t.integer "state"
    t.integer "tasked_for_id"
    t.string "tasked_for_type"
    t.integer "tenant_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.text "validation"
    t.index ["customer_id"], name: "index_tasks_on_customer_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["tasked_for_type", "tasked_for_id"], name: "index_tasks_on_tasked_for"
    t.index ["tenant_id"], name: "index_tasks_on_tenant_id"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "allowed_ot_minutes"
    t.boolean "blocked"
    t.string "cell_phone"
    t.string "color"
    t.integer "contract_days_per_payroll"
    t.integer "contract_days_per_week"
    t.integer "contract_minutes"
    t.string "country"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.string "eu_state"
    t.string "hour_pay"
    t.integer "hour_rate_cent", default: 0
    t.decimal "hourly_rate", precision: 11, scale: 2, default: "0.0", null: false
    t.string "locale"
    t.string "name"
    t.string "ot1_add_hour_pay"
    t.integer "ot1_hour_add_cent", default: 0
    t.string "ot2_add_hour_pay"
    t.integer "ot2_hour_add_cent", default: 0
    t.string "payroll_team_ident"
    t.string "pbx_extension"
    t.datetime "punches_settled_at"
    t.integer "state", default: 0
    t.integer "tenant_id", null: false
    t.string "time_zone"
    t.datetime "tmp_overtime_allowed"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_teams_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "access_token"
    t.string "color"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email"
    t.integer "license", default: 0
    t.datetime "license_changed_at"
    t.datetime "license_expires_at"
    t.string "locale"
    t.string "name"
    t.string "pp_identification"
    t.string "send_eu_state_rrule"
    t.string "send_state_rrule"
    t.string "tax_number"
    t.string "time_zone"
    t.datetime "updated_at", null: false
  end

  create_table "time_materials", force: :cascade do |t|
    t.string "about"
    t.text "comment"
    t.datetime "created_at", null: false
    t.string "customer_id"
    t.string "customer_name"
    t.string "date"
    t.string "discount"
    t.string "erp_guid"
    t.boolean "is_free"
    t.boolean "is_invoice"
    t.boolean "is_offer"
    t.boolean "is_separate"
    t.integer "kilometers"
    t.text "location_comment"
    t.integer "lock_version"
    t.datetime "minutes_reloaded_at"
    t.integer "odo_from"
    t.datetime "odo_from_time"
    t.integer "odo_to"
    t.datetime "odo_to_time"
    t.integer "over_time", default: 0
    t.datetime "paused_at"
    t.string "product_id"
    t.string "product_name"
    t.string "project_id"
    t.string "project_name"
    t.text "push_log"
    t.string "pushed_erp_timestamp"
    t.string "quantity"
    t.string "rate"
    t.integer "registered_minutes"
    t.datetime "started_at"
    t.integer "state", default: 0
    t.text "task_comment"
    t.integer "tenant_id", null: false
    t.string "time"
    t.integer "time_spent"
    t.string "trip_purpose"
    t.string "unit"
    t.string "unit_price"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.date "wdate"
    t.index ["tenant_id"], name: "index_time_materials_on_tenant_id"
    t.index ["user_id"], name: "index_time_materials_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "birthday"
    t.boolean "blocked_from_punching", default: false
    t.string "cell_phone"
    t.string "color"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.integer "consumed_timestep"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.integer "eu_state", default: 0
    t.integer "failed_attempts", default: 0, null: false
    t.boolean "global_queries", default: false
    t.datetime "hired_at"
    t.decimal "hourly_rate", precision: 11, scale: 2, default: "0.0", null: false
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.integer "invitations_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.string "job_title"
    t.datetime "last_punched_at"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "locale", default: "en"
    t.datetime "locked_at"
    t.string "name"
    t.boolean "otp_enabled", default: false
    t.datetime "otp_enabled_at"
    t.boolean "otp_required_for_login"
    t.string "otp_secret_key"
    t.string "password_digest"
    t.string "pincode"
    t.string "pos_token"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.integer "sign_in_count", default: 0, null: false
    t.integer "state", default: 0
    t.integer "team_id", default: 1, null: false
    t.integer "tenant_id", null: false
    t.string "time_zone", default: "UTC"
    t.boolean "two_factor_app_enabled", default: false, null: false
    t.datetime "two_factor_app_enabled_at"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
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
  add_foreign_key "batches", "tenants"
  add_foreign_key "batches", "users"
  add_foreign_key "calendars", "tenants"
  add_foreign_key "calls", "tenants"
  add_foreign_key "customers", "tenants"
  add_foreign_key "dashboards", "tenants"
  add_foreign_key "dashboards", "tenants", on_delete: :cascade
  add_foreign_key "editor_blocks", "editor_documents", column: "document_id"
  add_foreign_key "editor_documents", "tenants"
  add_foreign_key "event_meta", "events"
  add_foreign_key "events", "calendars"
  add_foreign_key "events", "tenants"
  add_foreign_key "filters", "tenants"
  add_foreign_key "filters", "tenants"
  add_foreign_key "filters", "tenants"
  add_foreign_key "filters", "tenants", on_delete: :cascade
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoice_items", "products"
  add_foreign_key "invoice_items", "tenants"
  add_foreign_key "invoices", "customers"
  add_foreign_key "invoices", "tenants"
  add_foreign_key "locations", "tenants", on_delete: :cascade
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "products", "tenants"
  add_foreign_key "projects", "customers"
  add_foreign_key "projects", "tenants"
  add_foreign_key "provided_services", "tenants"
  add_foreign_key "provided_services", "users", column: "authorized_by_id"
  add_foreign_key "punch_cards", "tenants"
  add_foreign_key "punch_cards", "tenants", on_delete: :cascade
  add_foreign_key "punch_clocks", "locations", on_delete: :cascade
  add_foreign_key "punch_clocks", "tenants", on_delete: :cascade
  add_foreign_key "punches", "punch_cards", on_delete: :cascade
  add_foreign_key "punches", "tenants"
  add_foreign_key "punches", "tenants", on_delete: :cascade
  add_foreign_key "sessions", "users"
  add_foreign_key "settings", "tenants"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "taggings", "tags"
  add_foreign_key "taggings", "users"
  add_foreign_key "tags", "tenants"
  add_foreign_key "tags", "users"
  add_foreign_key "tasks", "customers"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "tenants"
  add_foreign_key "teams", "tenants"
  add_foreign_key "teams", "tenants", on_delete: :cascade
  add_foreign_key "time_materials", "tenants"
  add_foreign_key "time_materials", "users"
  add_foreign_key "users", "teams"
  add_foreign_key "users", "teams", on_delete: :cascade
  add_foreign_key "users", "tenants"
  add_foreign_key "users", "tenants", on_delete: :cascade
  add_foreign_key "users", "tenants", on_delete: :cascade
end
