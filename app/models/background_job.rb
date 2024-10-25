# create_table "background_jobs", force: :cascade do |t|
#   t.integer "tenant_id", null: false
#   t.integer "user_id"
#   t.integer "state", default: 0
#   t.string "job_klass"
#   t.text "params"
#   t.text "schedule"
#   t.datetime "next_run_at"
#   t.string "job_id"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.index ["tenant_id"], name: "index_background_jobs_on_tenant_id"
#   t.index ["user_id"], name: "index_background_jobs_on_user_id"
# end
#
class BackgroundJob < ApplicationRecord
  include Tenantable
  include Queueable

  enum :state, {
    in_active:        0,
    un_planned:       1,
    planned:          2,
    running:          3,
    failed:           4,
    finished:         5
  }

  belongs_to :user, optional: true

  scope :by_fulltext, ->(q) { where("job_klass LIKE ? or params LIKE ?", "%#{q}%", "%#{q}%") if q.present? }
  scope :by_job_klass, ->(job_klass) { where("job_klass LIKE ? or params LIKE ?", "%#{job_klass}%", "%#{job_klass}%") if job_klass.present? }

  validates :job_klass, presence: true

  def name
    job_klass
  end

  def active?
    !in_active?
  end

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_job_klass(flt["job_klass"])
  rescue
    filter.destroy if filter
    all
  end

  def self.job_klasses
    [
      [ "DatalonPreparationJob", "DatalonPreparationJob" ],
      [ "UserAutoPunchJob", "UserAutoPunchJob" ],
      [ "UserEuStateJob", "UserEuStateJob" ],
      [ "UserStateJob", "UserStateJob" ],
      [ "ImportUsersJob", "ImportUsersJob" ],
      [ "PunchCardJob", "PunchCardJob" ],
      [ "PunchJob", "PunchJob" ]
    ]
  end

  def self.form(resource:, editable: true)
    BackgroundJobs::Form.new resource: resource, editable: editable
  end
end
