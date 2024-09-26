require "application_system_test_case"

class PunchesTest < ApplicationSystemTestCase
  setup do
    @punch = punches(:one)
    user = users(:superadmin)
    sign_in user
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

require "application_system_test_case"

class TeamsTest < ApplicationSystemTestCase
  setup do
    @team = teams(:one)
    user = users(:superadmin)
    sign_in user
  end

  test "visiting the index" do
    visit teams_url
    assert_selector "h1", text: "Hold/grupper"
  end

  test "should not create team with same name" do
    visit teams_url
    click_on "Nyt hold"

    fill_in "team_name", with: @team.name
    select "Dansk", from: "team_locale"
    select "Grå", from: "team_color"
    select "Europe/Copenhagen - (GMT+01:00) Copenhagen", from: "team_time_zone"
    click_on "Opret"

    assert_text "Hold navn already exists"
  end

  test "should create team" do
    visit teams_url
    click_on "Nyt hold"

    fill_in "team_name", with: "nyt hold"
    select "Dansk", from: "team_locale"
    select "Grå", from: "team_color"
    select "Europe/Copenhagen - (GMT+01:00) Copenhagen", from: "team_time_zone"
    click_on "Opret"

    assert_text "Holdet blev oprettet"
  end

  test "should update Team" do
    visit edit_team_url(@team)

    fill_in "team_name", with: "nyt hold"
    select "Dansk", from: "team_locale"
    select "Grå", from: "team_color"
    select "Europe/Copenhagen - (GMT+01:00) Copenhagen", from: "team_time_zone"
    click_on "Opdatér"

    assert_text "Holdet blev opdateret"
  end

  test "should destroy Team" do
    visit teams_url
    team_name = teams(:two).name
    team_li = find("li", text: team_name)
    within(team_li) do
      click_on "Open item options", match: :first
      click_on "Slet"
    end
    within("dialog#new_form_modal") do
      assert_text "Slet dette hold"
      save_screenshot("test.png")
      click_on "Slet"
    end

    assert_text "Posten blev slettet korrekt"
  end
end
