require "application_system_test_case"

class CallsTest < ApplicationSystemTestCase
  setup do
    @call = calls(:one)
  end

  test "visiting the index" do
    visit calls_url
    assert_selector "h1", text: "Calls"
  end

  test "should create call" do
    visit calls_url
    click_on "New call"

    fill_in "Direction", with: @call.direction
    fill_in "Phone", with: @call.phone
    fill_in "Tenant", with: @call.tenant_id
    click_on "Create Call"

    assert_text "Call was successfully created"
    click_on "Back"
  end

  test "should update Call" do
    visit call_url(@call)
    click_on "Edit this call", match: :first

    fill_in "Direction", with: @call.direction
    fill_in "Phone", with: @call.phone
    fill_in "Tenant", with: @call.tenant_id
    click_on "Update Call"

    assert_text "Call was successfully updated"
    click_on "Back"
  end

  test "should destroy Call" do
    visit call_url(@call)
    click_on "Destroy this call", match: :first

    assert_text "Call was successfully destroyed"
  end
end
