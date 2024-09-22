require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:one)
  end

  test "should get index" do
    get events_url
    assert_response :success
  end

  test "should get new" do
    get new_event_url
    assert_response :success
  end

  test "should create event" do
    assert_difference("Event.count") do
      post events_url, params: { event: { tenant_id: @event.tenant_id, all_day: @event.all_day, calendar_id: @event.calendar_id, comment: @event.comment, duration: @event.duration, from_date: @event.from_date, from_time: @event.from_time, name: @event.name, to_date: @event.to_date, to_datetime: @event.to_datetime } }
    end

    assert_redirected_to event_url(Event.last)
  end

  test "should show event" do
    get event_url(@event)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_url(@event)
    assert_response :success
  end

  test "should update event" do
    patch event_url(@event), params: { event: { tenant_id: @event.tenant_id, all_day: @event.all_day, calendar_id: @event.calendar_id, comment: @event.comment, duration: @event.duration, from_date: @event.from_date, from_time: @event.from_time, name: @event.name, to_date: @event.to_date, to_datetime: @event.to_datetime } }
    assert_redirected_to event_url(@event)
  end

  test "should destroy event" do
    assert_difference("Event.count", -1) do
      delete event_url(@event)
    end

    assert_redirected_to events_url
  end
end
