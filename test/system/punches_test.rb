require "application_system_test_case"

class PunchesTest < ApplicationSystemTestCase
  setup do
    @punch = punches(:one)
    user = users(:superadmin)
    ui_sign_in user
  end

  test "visiting the index" do
    visit punches_url
    assert_selector "h1", text: "Stemplinger"
  end

  test "should create punch" do
    visit punches_url
    click_on "Ny stempling"

    select "User Own PunchClock", from: "punch_punch_clock_id"
    fill_in "punch_punched_at", with: @punch.punched_at
    select "Ind", from: "punch_state"
    fill_in "punch_comment", with: @punch.comment
    click_on "Opret"

    assert_text "Stemplingen blev oprettet"
  end

  test "should update Punch" do
    visit punch_url(@punch)
    click_on "Edit this punch", match: :first

    fill_in "Tenant", with: @punch.tenant_id
    fill_in "User", with: @punch.user_id
    fill_in "Punch clock", with: @punch.punch_clock
    fill_in "Punched at", with: @punch.punched_at.to_s
    fill_in "Remote ip", with: @punch.remote_ip
    fill_in "State", with: @punch.state
    click_on "Update Punch"

    assert_text "Punch was successfully updated"
    click_on "Back"
  end

  test "should destroy Punch" do
    visit punch_url(@punch)
    click_on "Destroy this punch", match: :first

    assert_text "Punch was successfully destroyed"
  end
end
