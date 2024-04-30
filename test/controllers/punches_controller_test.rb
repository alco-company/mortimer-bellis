require "test_helper"

class PunchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @punch = punches(:one)
  end

  test "should get index" do
    get punches_url
    assert_response :success
  end

  test "should get new" do
    get new_punch_url
    assert_response :success
  end

  test "should create punch" do
    assert_difference("Punch.count") do
      post punches_url, params: { punch: { account_id: @punch.account_id, employee_id: @punch.employee_id, punch_clock: @punch.punch_clock, punched_at: @punch.punched_at, remote_ip: @punch.remote_ip, state: @punch.state } }
    end

    assert_redirected_to punch_url(Punch.last)
  end

  test "should show punch" do
    get punch_url(@punch)
    assert_response :success
  end

  test "should get edit" do
    get edit_punch_url(@punch)
    assert_response :success
  end

  test "should update punch" do
    patch punch_url(@punch), params: { punch: { account_id: @punch.account_id, employee_id: @punch.employee_id, punch_clock: @punch.punch_clock, punched_at: @punch.punched_at, remote_ip: @punch.remote_ip, state: @punch.state } }
    assert_redirected_to punch_url(@punch)
  end

  test "should destroy punch" do
    assert_difference("Punch.count", -1) do
      delete punch_url(@punch)
    end

    assert_redirected_to punches_url
  end
end
