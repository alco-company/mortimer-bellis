require "test_helper"

class QueueableDummy
  # Provide a no-op after_save to satisfy the concern’s included block
  class << self
    def after_save(*); end
  end

  include Queueable

  attr_accessor :schedule, :next_run_at
  attr_reader :ran_at, :saved_job_id, :saved_next_run_at

  def initialize
    @active_flag = true
    @schedule = "* * * * *"
    @next_run_return = nil
  end

  # Control activeness
  def active=(val); @active_flag = !!val; end
  def active?; @active_flag; end

  # Stub next_run to return a controlled epoch (Integer)
  def next_run(_schedule, _first = true)
    @next_run_return
  end
  def next_run_return=(epoch_int)
    @next_run_return = epoch_int
  end

  # Record what plan_job decides to run
  def run_job(t = nil)
    @ran_at = t
    persist "jid-1", t
  end

  # Don’t touch DB; just record persisted values
  def persist(job_id, next_run_at)
    @saved_job_id = job_id
    @saved_next_run_at = next_run_at
    [ job_id, next_run_at ]
  end

  # Disable feature gating inside run_job
  def shouldnt?(_key); false; end

  # Silence rescue logging
  def say(*); end
end

class QueueableTest < ActiveSupport::TestCase
  def epoch_in(seconds)
    (Time.now + seconds).to_i
  end

  test "plan_job chooses earlier of schedule time and existing next_run_at when both are in the future (picks schedule)" do
    d = QueueableDummy.new
    schedule_earlier = epoch_in(30.minutes)
    existing_later   = epoch_in(2.hours)

    d.next_run_return = schedule_earlier
    d.next_run_at     = existing_later

    d.plan_job

    assert_equal schedule_earlier, d.ran_at, "Expected plan_job to pick earlier schedule time"
    assert_equal schedule_earlier, d.saved_next_run_at, "Expected persist to save earlier schedule time"
  end

  test "plan_job chooses earlier of schedule time and existing next_run_at when both are in the future (keeps existing)" do
    d = QueueableDummy.new
    schedule_later   = epoch_in(2.hours)
    existing_earlier = epoch_in(30.minutes)

    d.next_run_return = schedule_later
    d.next_run_at     = existing_earlier

    d.plan_job

    assert_equal existing_earlier, d.ran_at, "Expected plan_job to keep earlier existing next_run_at"
    assert_equal existing_earlier, d.saved_next_run_at, "Expected persist to save existing next_run_at"
  end

  test "plan_job with existing next_run_at in the past and schedule in the future prefers the past existing time" do
    d = QueueableDummy.new
    schedule_future = epoch_in(30.minutes)
    existing_past   = epoch_in(-60.minutes)

    d.next_run_return = schedule_future
    d.next_run_at     = existing_past

    d.plan_job

    assert_equal existing_past, d.ran_at, "Expected plan_job to select existing past next_run_at per current logic"
    assert_equal existing_past, d.saved_next_run_at
  end

  test "plan_job schedules when only schedule returns a time and no existing next_run_at" do
    d = QueueableDummy.new
    schedule_future = epoch_in(15.minutes)

    d.next_run_return = schedule_future
    d.next_run_at     = nil

    d.plan_job

    assert_equal schedule_future, d.ran_at
    assert_equal schedule_future, d.saved_next_run_at
  end

  test "plan_job clears next_run when inactive" do
    d = QueueableDummy.new
    d.active = false
    d.next_run_return = epoch_in(10.minutes)
    d.next_run_at     = epoch_in(20.minutes)

    d.plan_job

    assert_nil d.ran_at, "Inactive should not schedule"
    assert_nil d.saved_job_id
    assert_nil d.saved_next_run_at, "Inactive should persist nils"
  end

  test "plan_job clears next_run when schedule yields nil" do
    d = QueueableDummy.new
    d.next_run_return = nil
    d.next_run_at     = epoch_in(20.minutes)

    d.plan_job

    assert_nil d.ran_at
    assert_nil d.saved_job_id
    assert_nil d.saved_next_run_at
  end
end
