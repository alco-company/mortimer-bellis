require "application_system_test_case"

class DashboardsTest < ApplicationSystemTestCase
  setup do
    @dashboard = dashboards(:one)
    @user = users(:one)
    sign_in @user
  end

  test "visiting the index - with user out" do
    @user.update state: "out"
    visit dashboards_url
    assert_selector "h2", text: "Oversigt"
    within "#punch_button" do
      assert_selector "button", text: "in"
    end
  end

  test "visiting the index - with user in" do
    @user.update state: "in"
    visit dashboards_url
    assert_selector "h2", text: "Oversigt"
    within "#punch_button" do
      assert_selector "button", text: "out"
      assert_selector "button", text: "break"
    end
  end

  test "visiting the index - with user in, and punch break" do
    @user.update state: "in"
    visit dashboards_url
    assert_selector "h2", text: "Oversigt"
    within "#punch_button" do
      assert_selector "button", text: "break"
      click_on "break"
    end
    within "table" do
      assert_selector "tr", text: "Pause", match: :first
    end
  end

  # test "should create dashboard" do
  #   visit dashboards_url
  #   click_on "New dashboard"

  #   fill_in "Tenant", with: @dashboard.tenant_id
  #   fill_in "Feed", with: @dashboard.feed
  #   click_on "Create Dashboard"

  #   assert_text "Dashboard was successfully created"
  #   click_on "Back"
  # end

  # test "should update Dashboard" do
  #   visit dashboard_url(@dashboard)
  #   click_on "Edit this dashboard", match: :first

  #   fill_in "Tenant", with: @dashboard.tenant_id
  #   fill_in "Feed", with: @dashboard.feed
  #   click_on "Update Dashboard"

  #   assert_text "Dashboard was successfully updated"
  #   click_on "Back"
  # end

  # test "should destroy Dashboard" do
  #   visit dashboard_url(@dashboard)
  #   click_on "Destroy this dashboard", match: :first

  #   assert_text "Dashboard was successfully destroyed"
  # end
end
