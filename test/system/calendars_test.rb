require "application_system_test_case"

class CalendarsTest < ApplicationSystemTestCase
  setup do
    @calendar = calendars(:one)
  end

  test "visiting the index" do
    visit calendars_url
    assert_selector "h1", text: "Calendars"
  end

  test "should create calendar" do
    visit calendars_url
    click_on "New calendar"

    fill_in "Tenant", with: @calendar.tenant_id
    fill_in "Calendarable", with: @calendar.calendarable_id
    fill_in "Calendarable type", with: @calendar.calendarable_type
    fill_in "Name", with: @calendar.name
    click_on "Create Calendar"

    assert_text "Calendar was successfully created"
    click_on "Back"
  end

  test "should update Calendar" do
    visit calendar_url(@calendar)
    click_on "Edit this calendar", match: :first

    fill_in "Tenant", with: @calendar.tenant_id
    fill_in "Calendarable", with: @calendar.calendarable_id
    fill_in "Calendarable type", with: @calendar.calendarable_type
    fill_in "Name", with: @calendar.name
    click_on "Update Calendar"

    assert_text "Calendar was successfully updated"
    click_on "Back"
  end

  test "should destroy Calendar" do
    visit calendar_url(@calendar)
    click_on "Destroy this calendar", match: :first

    assert_text "Calendar was successfully destroyed"
  end
end
