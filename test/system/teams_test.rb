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
