require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @event = events(:one)
  end

  test "visiting the index" do
    visit events_url
    assert_selector "h1", text: "Events"
  end

  test "should create event" do
    visit events_url
    click_on "New event"

    fill_in "Account", with: @event.account_id
    check "All day" if @event.all_day
    fill_in "Calendar", with: @event.calendar_id
    fill_in "Comment", with: @event.comment
    fill_in "Duration", with: @event.duration
    fill_in "From date", with: @event.from_date
    fill_in "From time", with: @event.from_time
    fill_in "Name", with: @event.name
    fill_in "To date", with: @event.to_date
    fill_in "To datetime", with: @event.to_datetime
    click_on "Create Event"

    assert_text "Event was successfully created"
    click_on "Back"
  end

  test "should update Event" do
    visit event_url(@event)
    click_on "Edit this event", match: :first

    fill_in "Account", with: @event.account_id
    check "All day" if @event.all_day
    fill_in "Calendar", with: @event.calendar_id
    fill_in "Comment", with: @event.comment
    fill_in "Duration", with: @event.duration
    fill_in "From date", with: @event.from_date
    fill_in "From time", with: @event.from_time.to_s
    fill_in "Name", with: @event.name
    fill_in "To date", with: @event.to_date
    fill_in "To datetime", with: @event.to_datetime.to_s
    click_on "Update Event"

    assert_text "Event was successfully updated"
    click_on "Back"
  end

  test "should destroy Event" do
    visit event_url(@event)
    click_on "Destroy this event", match: :first

    assert_text "Event was successfully destroyed"
  end
end
