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
  include Settingable
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

  def self.BACKGROUND_STATES = [
    [ "in_active",        I18n.t("background_job.states.in_active") ],
    [ "un_planned",       I18n.t("background_job.states.un_planned") ],
    [ "planned",          I18n.t("background_job.states.planned") ],
    [ "running",          I18n.t("background_job.states.running") ],
    [ "failed",           I18n.t("background_job.states.failed") ],
    [ "finished",         I18n.t("background_job.states.finished") ]
  ]

  belongs_to :user, optional: true

  scope :by_fulltext, ->(q) { where("job_klass LIKE ? or params LIKE ?", "%#{q}%", "%#{q}%") if q.present? }
  scope :by_job_klass, ->(job_klass) { where("job_klass LIKE ? or params LIKE ?", "%#{job_klass}%", "%#{job_klass}%") if job_klass.present? }
  scope :any_jobs_to_run, -> { where(state: 1..2, next_run_at: [ nil, ..DateTime.current ]) }

  validates :job_klass, presence: true

  before_destroy :cancel_active_job
  before_update :cancel_active_job_if_deactivated

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

  def self.user_scope(scope)
    case scope
    when "all"; nil # all.by_tenant()
    when "mine"; TimeMaterial.arel_table[:user_id].eq(Current.user.id)
    when "my_team"; TimeMaterial.arel_table[:user_id].in(Current.user.team.users.pluck(:id))
    end
  end

  def self.named_scope(scope)
    TimeMaterial.arel_table[:user_id].
    in(
      User.arel_table.project(:id).where(
        User[:name].matches("%#{scope}%").
        or(User[:team_id].in(Team.arel_table.project(:id).where(Team[:name].matches("%#{scope}%"))))
      )
    )
  end

  def self.filterable_fields(model = self)
    f = column_names - [
      "id",
      "tenant_id",
      "user_id"
      # "state",
      # "job_klass",
      # "params",
      # "schedule",
      # "next_run_at",
      # "job_id"
      # t.datetime "created_at", null: false
      # t.datetime "updated_at", null: false
    ]
    f = f - [
      "next_run_at",
      "created_at",
      "updated_at"
    ] if model == self
    f
  end

  def self.set_order(resources, field = :job_klass, direction = :asc)
    resources.ordered(field, direction)
  end

  def self.job_klasses
    [
      # [ "DatalonPreparationJob", "DatalonPreparationJob" ],
      # [ "UserAutoPunchJob", "UserAutoPunchJob" ],
      # [ "UserEuStateJob", "UserEuStateJob" ],
      # [ "UserStateJob", "UserStateJob" ],
      # [ "ImportUsersJob", "ImportUsersJob" ],
      # [ "PunchCardJob", "PunchCardJob" ],
      [ "RefreshErpTokenJob", "RefreshErpTokenJob" ],
      [ "BackupTenantJob", "BackupTenantJob" ],
      # [ "PunchReminderJob", "PunchReminderJob" ],
      [ "PunchJob", "PunchJob" ]
    ]
  end

  def self.form(resource:, editable: true)
    BackgroundJobs::Form.new resource: resource, editable: editable
  end

  def self.toggle
    bj = Tenant.first.background_jobs.first || Tenant.first.background_jobs.build
    zting = Tenant.first.settings.where(setable_type: "BackgroundJob", setable_id: nil, key: "run").take || Tenant.first.settings.create(setable_type: "BackgroundJob", setable_id: nil, key: "run", value: "true")
    if bj.shouldnt?(:run)
      zting.update value: "true"
    else
      zting.update value: "false"
    end
  end

  private

    # Cancel the ActiveJob in SolidQueue when this BackgroundJob is destroyed
    def cancel_active_job
      return unless job_id.present?
      return unless planned? || running?

      begin
        # Find and discard the job in SolidQueue
        solid_job = SolidQueue::Job.find_by(active_job_id: job_id)
        solid_job&.discard
        Rails.logger.info "Cancelled SolidQueue job #{job_id} for BackgroundJob #{id}"
      rescue => e
        Rails.logger.warn "Failed to cancel SolidQueue job #{job_id}: #{e.message}"
      end
    end

    # Cancel the ActiveJob when state changes away from planned/running
    def cancel_active_job_if_deactivated
      return unless job_id.present?
      return unless state_changed?

      # If changing from planned/running to something else (inactive, unplanned, failed, finished)
      old_state = state_was
      new_state = state
      was_active = old_state == "planned" || old_state == "running"
      now_inactive = new_state == "in_active" || new_state == "un_planned"

      if was_active && now_inactive
        cancel_active_job
      end
    end

    def finish_job
      new_state = failed? ? state : "finished"
      cancel_active_job
      update!(state: new_state, job_id: nil, next_run_at: nil)
    end
end
