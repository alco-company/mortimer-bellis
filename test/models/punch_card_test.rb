require "test_helper"

class PunchCardTest < ActiveSupport::TestCase
  def setup
    @employee = employees :one
    @punch_clock = punch_clocks :one
  end

  test "test one punch settings ok" do
    assert @employee.out?
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"in", "id"=>"93", "punched_at"=>"2024-06-15T07:55:14" } }
    Time.use_zone(@employee.time_zone) { @employee.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    assert Punch.count == 1
    assert @employee.punches.last.in?
    assert Time.use_zone(@employee.time_zone) { Time.zone.parse(punch_params["employee"]["punched_at"]) == Punch.last.punched_at.to_datetime }
  end

  test "test two punches" do
    assert @employee.out?
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"in", "id"=>"93", "punched_at"=>"2024-06-15T07:55:14" } }
    Time.use_zone(@employee.time_zone) { @employee.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"out", "id"=>"93", "punched_at"=>"2024-06-15T14:55:14" } }
    Time.use_zone(@employee.time_zone) { @employee.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    assert Punch.count == 2
    assert @employee.punches.last.out?
    assert Time.use_zone(@employee.time_zone) { Time.zone.parse(punch_params["employee"]["punched_at"]) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(employee: @employee, date: Punch.last.punched_at.to_date)
    assert PunchCard.last.work_minutes == 420
  end

  test "test two punches - in and break" do
    assert @employee.out?
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"in", "id"=>"93", "punched_at"=>"2024-06-15T07:55:14" } }
    Time.use_zone(@employee.time_zone) { @employee.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"break", "id"=>"93", "punched_at"=>"2024-06-15T9:55:14" } }
    Time.use_zone(@employee.time_zone) { @employee.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    assert Punch.count == 2
    assert @employee.punches.last.break?
    assert Time.use_zone(@employee.time_zone) { Time.zone.parse(punch_params["employee"]["punched_at"]) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(employee: @employee, date: Punch.last.punched_at.to_date)
    assert PunchCard.last.work_minutes == 120
  end

  test "test punch range settings ok" do
    assert @employee.out?
    punch_params = { "punch"=>{ "reason"=>"in", "from_at"=>"2024-06-16T07:30:00", "to_at"=>"2024-06-16T15:45:00", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      account: @employee.account, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", employee: @employee,
      from_at: punch_params["punch"]["from_at"],
      to_at: punch_params["punch"]["to_at"], comment: "123")
    assert Punch.count == 2
    assert @employee.punches.last.out?
    assert Time.use_zone(@employee.time_zone) { Time.zone.parse(punch_params["punch"]["to_at"]) == Punch.last.punched_at.to_datetime }
  end

  test "recalculating punch_card" do
    punch_params = { "punch"=>{ "reason"=>"in", "from_at"=>"2024-06-16T07:30:00", "to_at"=>"2024-06-16T15:45:00", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      account: @employee.account, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", employee: @employee,
      from_at: punch_params["punch"]["from_at"],
      to_at: punch_params["punch"]["to_at"], comment: "123")
    PunchCard.recalculate(employee: @employee, date: Punch.last.punched_at.to_date)
    assert PunchCard.count == 1
    assert PunchCard.last.punches.size == 2
    assert_equal PunchCard.last.work_minutes, 495
  end

  test "recalculating punch_card - 3 days straigth" do
    punch_params = { "punch"=>{ "reason"=>"in", "from_at"=>"2024-06-16T10:00:00", "to_at"=>"2024-06-18T18:00:00", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      account: @employee.account, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", employee: @employee,
      from_at: punch_params["punch"]["from_at"],
      to_at: punch_params["punch"]["to_at"], comment: "123")
    assert Punch.count == 6
    assert PunchCard.count == 3
    assert PunchCard.last.punches.size == 2
    assert_equal PunchCard.last.work_minutes, 480
  end

  test "recalculating punch_card across midnight - but effectively on one PunchCard!" do
    punch_params = { "punch"=>{ "reason"=>"in", "from_at"=>"2024-06-16T23:30:00", "to_at"=>"2024-06-17T00:45:00", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      account: @employee.account, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", employee: @employee,
      from_at: punch_params["punch"]["from_at"],
      to_at: punch_params["punch"]["to_at"], comment: "123")
    PunchCard.recalculate(employee: @employee, date: Punch.last.punched_at.to_date)
    assert PunchCard.count == 1
    assert PunchCard.last.punches.size == 2
    assert_equal PunchCard.last.work_minutes, 75
  end

  test "recalculating punch_card across midnight" do
    punch_params = { "punch"=>{ "reason"=>"in", "from_at"=>"2024-06-16T23:30:00", "to_at"=>"2024-06-17T02:45:00", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      account: @employee.account, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", employee: @employee,
      from_at: punch_params["punch"]["from_at"],
      to_at: punch_params["punch"]["to_at"], comment: "123")
    PunchCard.recalculate(employee: @employee, date: Punch.last.punched_at.to_date)
    assert PunchCard.count == 1
    assert PunchCard.last.punches.size == 2
    assert_equal PunchCard.last.work_minutes, 195
  end

  test "test two punches - in, out - across midnight" do
    p_at = nil
    assert @employee.out?
    [ [ "2024-06-15T21:55:14", "in" ], [ "2024-06-16T06:55:14", "out" ] ].each do |punched_at, state|
      punch_params = { "employee"=> { "api_key"=>"123", "state"=> state, "id"=>"93", "punched_at"=> punched_at } }
      Time.use_zone(@employee.time_zone) { @employee.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
      p_at = punched_at
    end
    assert Punch.count == 2
    assert @employee.punches.last.out?
    assert Time.use_zone(@employee.time_zone) { Time.zone.parse(p_at) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(employee: @employee, date: Punch.last.punched_at.to_date)
    assert PunchCard.count == 1
    assert PunchCard.last.work_minutes == 540
  end

  test "test four punches - in, break, in, out - across midnight" do
    p_at = nil
    assert @employee.out?
    [ [ "2024-06-15T21:55:14", "in" ], [ "2024-06-15T23:55:14", "break" ], [ "2024-06-16T0:15:14", "in" ], [ "2024-06-16T03:55:14", "out" ] ].each do |punched_at, state|
      punch_params = { "employee"=> { "api_key"=>"123", "state"=> state, "id"=>"93", "punched_at"=> punched_at } }
      Time.use_zone(@employee.time_zone) { @employee.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
      p_at = punched_at
    end
    assert Punch.count == 4
    assert @employee.punches.last.out?
    assert Time.use_zone(@employee.time_zone) { Time.zone.parse(p_at) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(employee: @employee, date: Punch.last.punched_at.to_date)
    assert PunchCard.last.work_minutes == 340
    assert PunchCard.last.break_minutes == 20
  end

  test "test three punches - in, break, in " do
    p_at = nil
    [ [ "2024-06-15T21:55:14", "in" ],
      [ "2024-06-15T22:55:14", "break" ],
      [ "2024-06-15T23:15:14", "in" ] ].each do |punched_at, state|
      punch_params = { "employee"=> { "api_key"=>"123", "state"=> state, "id"=>"93", "punched_at"=> punched_at } }
      Time.use_zone(@employee.time_zone) { @employee.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
      p_at = punched_at
    end
    assert Punch.count == 3
    assert @employee.punches.last.in?
    assert Time.use_zone(@employee.time_zone) { Time.zone.parse(p_at) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(employee: @employee, date: Punch.last.punched_at.to_date)
    assert PunchCard.last.work_minutes == 60
    assert PunchCard.last.break_minutes == 20
  end

  test "test five punches - in, break, in, break, in - forgot to punch out - and across midnight" do
    p_at = nil
    [ [ "2024-06-15T21:55:14", "in" ],
      [ "2024-06-15T23:55:14", "break" ],
      [ "2024-06-16T0:15:14", "in" ],
      [ "2024-06-16T02:15:14", "break" ],
      [ "2024-06-16T03:55:14", "in" ] ].each do |punched_at, state|
      punch_params = { "employee"=> { "api_key"=>"123", "state"=> state, "id"=>"93", "punched_at"=> punched_at } }
      Time.use_zone(@employee.time_zone) { @employee.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
      p_at = punched_at
    end
    assert Punch.count == 5
    assert @employee.punches.last.in?
    assert Time.use_zone(@employee.time_zone) { Time.zone.parse(p_at) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(employee: @employee, date: Punch.last.punched_at.to_date)
    assert PunchCard.last.work_minutes == -1
  end

  test "recalculating punch_card - 3 days straigth being sick" do
    punch_params = { "punch"=>{ "reason"=>"sick", "from_at"=>"2024-06-16T10:00:00", "to_at"=>"2024-06-18T18:00:00", "comment"=>"bollocks" } }
    PunchJob.perform_now(
      account: @employee.account, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", employee: @employee,
      from_at: punch_params["punch"]["from_at"],
      to_at: punch_params["punch"]["to_at"], comment: "shit days")
    assert Punch.count == 6
    assert PunchCard.count == 3
    assert PunchCard.last.punches.size == 2
    assert_equal 0, PunchCard.last.work_minutes
  end

  test "working a full weekend except 20/-21/6" do
    punch_params = { "punch"=>{ "reason"=>"in",
      "from_at"=>"2024-06-17T7:00:00",
      "to_at"=>"2024-06-23T15:30:00",
      "comment"=>"normal dag",
      "days"=>[ "monday", "tuesday", "wednesday", "thursday", "friday" ],
      "excluded_days"=>"20/6-21/6"
    } }
    @employee.punch_range punch_params["punch"], "1.2.3.4"
    assert_equal Punch.count, 6
    assert_equal PunchCard.count, 3
    assert_equal PunchCard.last.punches.size, 2
    assert_equal PunchCard.all.sum(:work_minutes), 1530
  end
end
