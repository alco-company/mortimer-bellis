require "application_system_test_case"

class CalendarsTest < ApplicationSystemTestCase
  setup do
    @calendar = calendars(:one)
    user = users(:superadmin)
    sign_in user
  end

  test "visiting the index" do
    visit calendars_url
    assert_selector "h1", text: "Kalendere"
  end

  test "should create calendar" do
    visit calendars_url
    click_on "Ny kalender"

    fill_in "Navn", with: "ny kalender"
    fill_in "calendar_calendarable_id", with: @calendar.calendarable_id
    fill_in "calendar_calendarable_type", with: @calendar.calendarable_type
    click_on "Opret"

    assert_text "Kalenderen blev oprettet"
  end

  test "should update Calendar" do
    visit edit_calendar_url(@calendar)

    fill_in "Navn", with: "ny kalender"
    fill_in "calendar_calendarable_id", with: @calendar.calendarable_id
    fill_in "calendar_calendarable_type", with: @calendar.calendarable_type
    click_on "Opdatér"

    assert_text "Kalenderen blev opdateret"
  end

  test "should destroy Calendar" do
    visit calendar_url(@calendar)
    click_on "Destroy this calendar", match: :first

    assert_text "Calendar was successfully destroyed"
  end
end
