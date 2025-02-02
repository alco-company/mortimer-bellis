require "test_helper"

class PunchCardTest < ActiveSupport::TestCase
  def setup
    @user = employees :one
    @punch_clock = punch_clocks :one
  end

  test "test one punch settings ok" do
    assert @user.out?
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"in", "id"=>"93", "punched_at"=>"2024-06-15T07:55:14" } }
    Time.use_zone(@user.time_zone) { @user.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    assert Punch.count == 1
    assert @user.punches.last.in?
    assert Time.use_zone(@user.time_zone) { Time.zone.parse(punch_params["employee"]["punched_at"]) == Punch.last.punched_at.to_datetime }
  end

  test "test two punches" do
    assert @user.out?
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"in", "id"=>"93", "punched_at"=>"2024-06-15T07:55:14" } }
    Time.use_zone(@user.time_zone) { @user.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"out", "id"=>"93", "punched_at"=>"2024-06-15T14:55:14" } }
    Time.use_zone(@user.time_zone) { @user.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    assert Punch.count == 2
    assert @user.punches.last.out?
    assert Time.use_zone(@user.time_zone) { Time.zone.parse(punch_params["employee"]["punched_at"]) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
    assert PunchCard.last.work_minutes == 420
  end

  test "test two punches - in and break" do
    assert @user.out?
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"in", "id"=>"93", "punched_at"=>"2024-06-15T07:55:14" } }
    Time.use_zone(@user.time_zone) { @user.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    punch_params = { "employee"=> { "api_key"=>"123", "state"=>"break", "id"=>"93", "punched_at"=>"2024-06-15T9:55:14" } }
    Time.use_zone(@user.time_zone) { @user.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
    assert Punch.count == 2
    assert @user.punches.last.break?
    assert Time.use_zone(@user.time_zone) { Time.zone.parse(punch_params["employee"]["punched_at"]) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
    assert PunchCard.last.work_minutes == 120
  end

  test "test punch range settings ok" do
    assert @user.out?
    punch_params = { "punch"=>{ "reason"=>"in", "from_date"=>"2024-06-16", "from_time"=>"07:30", "to_date"=>"2024-06-16", "to_time"=>"15:45", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      tenant: @user.tenant, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", user: @user,
      from_date: punch_params["punch"]["from_date"],
      from_time: punch_params["punch"]["from_time"],
      to_date: punch_params["punch"]["to_date"],
      to_time: punch_params["punch"]["to_time"], comment: "123")
    assert Punch.count == 2
    assert @user.punches.last.out?
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
    assert_equal 5, Punch.first.punched_at.utc.hour
    assert_equal 13, Punch.last.punched_at.utc.hour
    assert_equal PunchCard.last.work_minutes, 495
  end

  test "recalculating punch_card" do
    punch_params = { "punch"=>{ "reason"=>"in", "from_date"=>"2024-06-16", "from_time"=>"07:30", "to_date"=>"2024-06-16", "to_time"=>"15:45", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      tenant: @user.tenant, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", user: @user,
      from_date: punch_params["punch"]["from_date"],
      from_time: punch_params["punch"]["from_time"],
      to_date: punch_params["punch"]["to_date"],
      to_time: punch_params["punch"]["to_time"], comment: "123")
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
    assert PunchCard.count == 1
    assert PunchCard.last.punches.size == 2
    assert_equal PunchCard.last.work_minutes, 495
  end

  test "recalculating punch_card - 3 days straigth" do
    punch_params = { "punch"=>{ "reason"=>"in", "from_date"=>"2024-06-16", "from_time"=>"10:00", "to_date"=>"2024-06-18", "to_time"=>"18:00", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      tenant: @user.tenant, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", user: @user,
      from_date: punch_params["punch"]["from_date"],
      from_time: punch_params["punch"]["from_time"],
      to_date: punch_params["punch"]["to_date"],
      to_time: punch_params["punch"]["to_time"], comment: "123")
    assert Punch.count == 6
    assert PunchCard.count == 3
    assert PunchCard.last.punches.size == 2
    assert_equal PunchCard.last.work_minutes, 480
  end

  test "recalculating punch_card across midnight - but effectively on one PunchCard!" do
    punch_params = { "punch"=>{ "reason"=>"in", "from_date"=>"2024-06-16", "from_time"=>"23:30", "to_date"=>"2024-06-17", "to_time"=>"00:45", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      tenant: @user.tenant, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", user: @user,
      from_date: punch_params["punch"]["from_date"],
      from_time: punch_params["punch"]["from_time"],
      to_date: punch_params["punch"]["to_date"],
      to_time: punch_params["punch"]["to_time"], comment: "123")
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
    assert_equal 1, PunchCard.count
    assert_equal 2, PunchCard.last.punches.size
    assert_equal PunchCard.last.work_minutes, 75
  end

  test "recalculating punch_card across midnight" do
    punch_params = { "punch"=>{ "reason"=>"in", "from_date"=>"2024-06-16", "from_time"=>"23:30", "to_date"=>"2024-06-17", "to_time"=>"02:45", "comment"=>"normal dag" } }
    PunchJob.perform_now(
      tenant: @user.tenant, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", user: @user,
      from_date: punch_params["punch"]["from_date"],
      from_time: punch_params["punch"]["from_time"],
      to_date: punch_params["punch"]["to_date"],
      to_time: punch_params["punch"]["to_time"], comment: "123")
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
    assert PunchCard.count == 1
    assert PunchCard.last.punches.size == 2
    assert_equal PunchCard.last.work_minutes, 195
  end

  test "test two punches - in, out - across midnight" do
    p_at = nil
    assert @user.out?
    [ [ "2024-06-15T21:55:14", "in" ], [ "2024-06-16T06:55:14", "out" ] ].each do |punched_at, state|
      punch_params = { "employee"=> { "api_key"=>"123", "state"=> state, "id"=>"93", "punched_at"=> punched_at } }
      Time.use_zone(@user.time_zone) { @user.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
      p_at = punched_at
    end
    assert Punch.count == 2
    assert @user.punches.last.out?
    assert Time.use_zone(@user.time_zone) { Time.zone.parse(p_at) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
    assert PunchCard.count == 1
    assert PunchCard.last.work_minutes == 540
  end

  test "test four punches - in, break, in, out - across midnight" do
    p_at = nil
    assert @user.out?
    [ [ "2024-06-15T21:55:14", "in" ], [ "2024-06-15T23:55:14", "break" ], [ "2024-06-16T0:15:14", "in" ], [ "2024-06-16T03:55:14", "out" ] ].each do |punched_at, state|
      punch_params = { "employee"=> { "api_key"=>"123", "state"=> state, "id"=>"93", "punched_at"=> punched_at } }
      Time.use_zone(@user.time_zone) { @user.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
      p_at = punched_at
    end
    assert Punch.count == 4
    assert @user.punches.last.out?
    assert Time.use_zone(@user.time_zone) { Time.zone.parse(p_at) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
    assert PunchCard.last.work_minutes == 340
    assert PunchCard.last.break_minutes == 20
  end

  test "test three punches - in, break, in " do
    p_at = nil
    [ [ "2024-06-15T21:55:14", "in" ],
      [ "2024-06-15T22:55:14", "break" ],
      [ "2024-06-15T23:15:14", "in" ] ].each do |punched_at, state|
      punch_params = { "employee"=> { "api_key"=>"123", "state"=> state, "id"=>"93", "punched_at"=> punched_at } }
      Time.use_zone(@user.time_zone) { @user.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
      p_at = punched_at
    end
    assert Punch.count == 3
    assert @user.punches.last.in?
    assert Time.use_zone(@user.time_zone) { Time.zone.parse(p_at) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
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
      Time.use_zone(@user.time_zone) { @user.punch @punch_clock, punch_params["employee"]["state"], "1.2.3.4", punch_params["employee"]["punched_at"] }
      p_at = punched_at
    end
    assert Punch.count == 5
    assert @user.punches.last.in?
    assert Time.use_zone(@user.time_zone) { Time.zone.parse(p_at) == Punch.last.punched_at.to_datetime }
    PunchCard.recalculate(user: @user, date: Punch.last.punched_at.to_date)
    assert_equal(-1, PunchCard.last.work_minutes)
  end

  test "recalculating punch_card - 3 days straigth being sick" do
    punch_params = { "punch"=>{ "reason"=>"sick", "from_date"=>"2024-06-16", "from_time"=>"10:00", "to_date"=>"2024-06-18", "to_time"=>"18:00", "comment"=>"bollocks" } }
    PunchJob.perform_now(
      tenant: @user.tenant, reason: punch_params["punch"]["reason"],
      ip: "1.2.3.4", user: @user,
      from_date: punch_params["punch"]["from_date"],
      from_time: punch_params["punch"]["from_time"],
      to_date: punch_params["punch"]["to_date"],
      to_time: punch_params["punch"]["to_time"], comment: "123")
    assert Punch.count == 6
    assert PunchCard.count == 3
    assert PunchCard.last.punches.size == 2
    assert_equal 0, PunchCard.last.work_minutes
  end

  test "working a full weekend except 20/-21/6" do
    punch_params = { "punch"=>{ "reason"=>"in",
      "from_date"=>"2024-06-17",
      "from_time"=>"07:00",
      "to_date"=>"2024-06-23",
      "to_time"=>"15:30",
      "comment"=>"normal dag",
      "days"=>[ "monday", "tuesday", "wednesday", "thursday", "friday" ],
      "excluded_days"=>"20/6-21/6"
    } }
    @user.punch_range punch_params["punch"], "1.2.3.4"
    assert_equal Punch.count, 6
    assert_equal PunchCard.count, 3
    assert_equal PunchCard.last.punches.size, 2
    assert_equal PunchCard.all.sum(:work_minutes), 1530
  end
end
