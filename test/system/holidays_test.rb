require "application_system_test_case"

class HolidaysTest < ApplicationSystemTestCase
  setup do
    @holiday = holidays(:one)
  end

  test "visiting the index" do
    visit holidays_url
    assert_selector "h1", text: "Holidays"
  end

  test "should create holiday" do
    visit holidays_url
    click_on "New holiday"

    fill_in "All day", with: @holiday.all_day
    fill_in "Countries", with: @holiday.countries
    fill_in "From date", with: @holiday.from_date
    fill_in "Name", with: @holiday.name
    fill_in "To date", with: @holiday.to_date
    click_on "Create Holiday"

    assert_text "Holiday was successfully created"
    click_on "Back"
  end

  test "should update Holiday" do
    visit holiday_url(@holiday)
    click_on "Edit this holiday", match: :first

    fill_in "All day", with: @holiday.all_day
    fill_in "Countries", with: @holiday.countries
    fill_in "From date", with: @holiday.from_date
    fill_in "Name", with: @holiday.name
    fill_in "To date", with: @holiday.to_date
    click_on "Update Holiday"

    assert_text "Holiday was successfully updated"
    click_on "Back"
  end

  test "should destroy Holiday" do
    visit holiday_url(@holiday)
    click_on "Destroy this holiday", match: :first

    assert_text "Holiday was successfully destroyed"
  end
end
