require "application_system_test_case"

class DashboardsTest < ApplicationSystemTestCase
  setup do
    @dashboard = dashboards(:one)
    @user = users(:one)
    ui_sign_in @user
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
end
