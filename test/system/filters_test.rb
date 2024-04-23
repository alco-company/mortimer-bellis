require "application_system_test_case"

class FiltersTest < ApplicationSystemTestCase
  setup do
    @filter = filters(:one)
  end

  test "visiting the index" do
    visit filters_url
    assert_selector "h1", text: "Filters"
  end

  test "should create filter" do
    visit filters_url
    click_on "New filter"

    fill_in "Account", with: @filter.account_id
    fill_in "Filter", with: @filter.filter
    fill_in "View", with: @filter.view
    click_on "Create Filter"

    assert_text "Filter was successfully created"
    click_on "Back"
  end

  test "should update Filter" do
    visit filter_url(@filter)
    click_on "Edit this filter", match: :first

    fill_in "Account", with: @filter.account_id
    fill_in "Filter", with: @filter.filter
    fill_in "View", with: @filter.view
    click_on "Update Filter"

    assert_text "Filter was successfully updated"
    click_on "Back"
  end

  test "should destroy Filter" do
    visit filter_url(@filter)
    click_on "Destroy this filter", match: :first

    assert_text "Filter was successfully destroyed"
  end
end
