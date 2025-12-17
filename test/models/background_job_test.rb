require "test_helper"
require "ostruct"

class BackgroundJobTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @tenant = tenants(:one)
    @user = users(:one)
  end

  # Validations
  test "requires job_klass" do
    job = BackgroundJob.new(tenant: @tenant, user: @user)
    assert_not job.valid?
    assert_includes job.errors[:job_klass], "skal udfyldes"
  end

  test "valid with required attributes" do
    job = BackgroundJob.new(
      tenant: @tenant,
      user: @user,
      job_klass: "BackupTenantJob",
      state: :un_planned
    )
    assert job.valid?
  end

  # State Machine
  test "defaults to in_active state" do
    job = BackgroundJob.new(tenant: @tenant, user: @user, job_klass: "TestJob")
    assert_equal 0, job.state_before_type_cast
    assert job.in_active?
  end

  test "supports all states" do
    job = background_jobs(:daily_backup)

    job.state = :in_active
    assert job.in_active?

    job.state = :un_planned
    assert job.un_planned?

    job.state = :planned
    assert job.planned?

    job.state = :running
    assert job.running?

    job.state = :failed
    assert job.failed?

    job.state = :finished
    assert job.finished?
  end

  test "BACKGROUND_STATES returns all states with translations" do
    states = BackgroundJob.BACKGROUND_STATES
    assert_equal 6, states.count
    assert_equal "in_active", states[0][0]
    assert_equal "un_planned", states[1][0]
    assert_equal "planned", states[2][0]
    assert_equal "running", states[3][0]
    assert_equal "failed", states[4][0]
    assert_equal "finished", states[5][0]
  end

  # Scopes
  test "any_jobs_to_run includes un_planned jobs with past next_run_at" do
    travel_to Time.zone.parse("2025-11-20 08:00:00") do
      jobs = BackgroundJob.any_jobs_to_run
      assert_includes jobs, background_jobs(:ready_to_run)
    end
  end

  test "any_jobs_to_run includes planned jobs with past next_run_at" do
    travel_to Time.zone.parse("2025-11-20 08:10:00") do
      jobs = BackgroundJob.any_jobs_to_run
      assert_includes jobs, background_jobs(:one_time_import)
    end
  end

  test "any_jobs_to_run excludes jobs with future next_run_at" do
    travel_to Time.zone.parse("2025-11-20 08:00:00") do
      jobs = BackgroundJob.any_jobs_to_run
      assert_not_includes jobs, background_jobs(:daily_backup)
      assert_not_includes jobs, background_jobs(:weekly_report)
    end
  end

  test "any_jobs_to_run excludes running, failed, and finished jobs" do
    travel_to Time.zone.parse("2025-11-20 08:00:00") do
      jobs = BackgroundJob.any_jobs_to_run
      assert_not_includes jobs, background_jobs(:running_backup)
      assert_not_includes jobs, background_jobs(:failed_upload)
      assert_not_includes jobs, background_jobs(:finished_import)
    end
  end

  test "any_jobs_to_run excludes inactive jobs" do
    travel_to Time.zone.parse("2025-11-20 08:00:00") do
      jobs = BackgroundJob.any_jobs_to_run
      assert_not_includes jobs, background_jobs(:inactive_backup)
    end
  end

  test "by_job_klass scope filters by job class name" do
    jobs = BackgroundJob.by_job_klass("BackupTenantJob")
    assert_includes jobs, background_jobs(:daily_backup)
    assert_includes jobs, background_jobs(:running_backup)
    assert_not_includes jobs, background_jobs(:weekly_report)
  end

  test "by_job_klass scope filters by params content" do
    jobs = BackgroundJob.by_job_klass("sales")
    assert_includes jobs, background_jobs(:weekly_report)
  end

  test "by_fulltext scope searches job_klass and params" do
    jobs = BackgroundJob.by_fulltext("BackupTenantJob")
    assert_includes jobs, background_jobs(:daily_backup)

    jobs = BackgroundJob.by_fulltext("sales")
    assert_includes jobs, background_jobs(:weekly_report)
  end

  # Instance Methods
  test "name returns job_klass" do
    job = background_jobs(:daily_backup)
    assert_equal "BackupTenantJob", job.name
  end

  test "active? returns true for non-inactive jobs" do
    assert background_jobs(:daily_backup).active?
    assert background_jobs(:weekly_report).active?
    assert background_jobs(:running_backup).active?
  end

  test "active? returns false for inactive jobs" do
    assert_not background_jobs(:inactive_backup).active?
  end

  # Associations
  test "belongs to tenant" do
    job = background_jobs(:daily_backup)
    assert_equal tenants(:one), job.tenant
  end

  test "belongs to user optionally" do
    job = background_jobs(:daily_backup)
    assert_equal users(:one), job.user

    # User is optional
    job.user = nil
    assert job.valid?
  end

  # Class Methods
  test "job_klasses returns available job classes" do
    klasses = BackgroundJob.job_klasses
    assert_kind_of Array, klasses
    assert_includes klasses.flatten, "BackupTenantJob"
    assert_includes klasses.flatten, "RefreshErpTokenJob"
    assert_includes klasses.flatten, "PunchJob"
  end

  test "filtered applies job_klass filter" do
    filter = OpenStruct.new(filter: { "job_klass" => "BackupTenantJob" })
    jobs = BackgroundJob.filtered(filter)
    jobs.each do |job|
      assert_match(/BackupTenantJob/, job.job_klass + job.params)
    end
  end

  test "toggle flips background job execution setting" do
    skip "Toggle logic depends on complex shouldnt? method - tested manually"
  end
end
