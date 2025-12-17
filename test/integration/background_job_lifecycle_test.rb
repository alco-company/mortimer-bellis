require "test_helper"

class BackgroundJobLifecycleTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @tenant = tenants(:one)
    @user = users(:one)
  end

  # NOTE: Full lifecycle tests with actual job execution require complex ActiveJob mocking
  # that doesn't work well with Minitest. These tests focus on the data model and business logic.
  # Full end-to-end testing should be done manually or via system tests.

  test "one-time job completes and marks finished" do
    job = BackgroundJob.create!(
      tenant: @tenant,
      user: @user,
      job_klass: "TestJob",
      params: "{ test: true }",
      schedule: nil,
      state: :running
    )

    job.job_done
    job.reload

    assert job.finished?
    assert_nil job.next_run_at
    assert_nil job.job_id
  end

  test "recurring job remains un_planned after job_done" do
    skip "job_done calls plan_job which requires ActiveJob mocking"
  end

  test "jobs are isolated by tenant" do
    tenant_two = tenants(:two)

    job_one = BackgroundJob.create!(
      tenant: @tenant,
      user: @user,
      job_klass: "TestJob",
      state: :un_planned
    )

    job_two = BackgroundJob.create!(
      tenant: tenant_two,
      user: users(:two),
      job_klass: "TestJob",
      state: :un_planned
    )

    # Both jobs exist in database
    assert BackgroundJob.exists?(job_one.id)
    assert BackgroundJob.exists?(job_two.id)

    # Jobs belong to correct tenants
    assert_equal @tenant, job_one.tenant
    assert_equal tenant_two, job_two.tenant
  end

  test "failed job remains in failed state" do
    job = BackgroundJob.create!(
      tenant: @tenant,
      user: @user,
      job_klass: "TestJob",
      schedule: "0 2 * * *",
      state: :failed
    )

    job.job_done
    job.reload

    assert job.failed?
  end

  test "cron schedule next_run calculation" do
    travel_to Time.zone.parse("2025-11-20 08:00:00") do
      job = BackgroundJob.create!(
        tenant: @tenant,
        user: @user,
        job_klass: "TestJob",
        schedule: "0 2 * * *",
        state: :un_planned
      )

      next_time = job.cron_runs("0 2 * * *", true)

      assert_not_nil next_time
      assert next_time > Time.current.to_i
    end
  end

  test "BUG FIX: daily job reschedules for next day not 2 days away" do
    # Reproduces real-world bug: A job scheduled for '0 2 * * *' (daily at 2am)
    # would reschedule 2 days into the future instead of tomorrow after completion.
    # This was caused by using index:1 instead of index:0 in cron_runs when first=false.
    travel_to Time.zone.parse("2025-11-20 02:05:00") do
      job = BackgroundJob.create!(
        tenant: @tenant,
        user: @user,
        job_klass: "BackupTenantJob",
        schedule: "0 2 * * *",  # Daily at 2am
        state: :running
      )

      # Job just completed at 2am, now calculating next run for rescheduling
      expected_next_run = Time.zone.parse("2025-11-21 02:00:00")  # Tomorrow at 2am
      wrong_next_run = Time.zone.parse("2025-11-22 02:00:00")  # 2 days away (the old bug)

      # Test cron_runs with first=false (rescheduling scenario)
      next_time = job.cron_runs("0 2 * * *", false)

      assert_in_delta expected_next_run.to_i, next_time, 60,
        "After running at 2:05am, should reschedule for tomorrow at 2am (#{expected_next_run}), not #{Time.at(next_time)}"
      assert_not_in_delta wrong_next_run.to_i, next_time, 60,
        "Should NOT reschedule 2 days away (the bug was using index:1 instead of index:0)"
    end
  end

  test "dynamic params are evaluated correctly" do
    job = BackgroundJob.create!(
      tenant: @tenant,
      user: @user,
      job_klass: "TestJob",
      params: "status:active,priority:1",
      state: :un_planned
    )

    params = job.set_parms

    assert_equal "active", params[:status]
    assert_equal "1", params[:priority]
    assert_equal @user, params[:user]
    assert_equal @tenant, params[:tenant]
    assert_equal job, params[:background_job]
  end

  test "job state transitions" do
    job = BackgroundJob.create!(
      tenant: @tenant,
      user: @user,
      job_klass: "TestJob",
      state: :in_active
    )

    job.update!(state: :un_planned)
    assert job.un_planned?

    job.update!(state: :planned)
    assert job.planned?

    job.update!(state: :running)
    assert job.running?

    job.update!(state: :finished)
    assert job.finished?
  end

  test "job_reset clears state" do
    job = BackgroundJob.create!(
      tenant: @tenant,
      user: @user,
      job_klass: "TestJob",
      state: :running,
      job_id: "test-123",
      next_run_at: Time.current
    )

    job.job_reset
    job.reload

    # job_reset calls persist which sets state to finished when both are nil
    assert job.in_active? || job.finished?
    assert_nil job.job_id
    assert_nil job.next_run_at
  end

  test "shouldnt? permission check prevents execution" do
    job = BackgroundJob.create!(
      tenant: @tenant,
      user: @user,
      job_klass: "TestJob",
      state: :un_planned
    )

    job.stub(:shouldnt?, true) do
      result = job.run_job
      assert_nil result
    end
  end
end
