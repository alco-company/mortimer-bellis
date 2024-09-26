require "application_system_test_case"

class SettingsTest < ApplicationSystemTestCase
  setup do
    @setting = settings(:one)
    user = users(:superadmin)
    sign_in user
  end

  test "visiting the index" do
    visit settings_url
    assert_selector "h1", text: "Indstillinger"
  end

  test "should not create setting with same key" do
    visit settings_url
    click_on "Ny indstilling"

    fill_in "setting_key", with: @setting.key
    fill_in "setting_setable_type", with: @setting.setable_type
    fill_in "setting_setable_id", with: @setting.setable_id
    fill_in "setting_priority", with: @setting.priority
    fill_in "setting_format", with: @setting.format
    fill_in "setting_value", with: @setting.value
    click_on "Opret"

    assert_text "Nøglen findes allerede"
  end

  test "should create setting" do
    visit settings_url
    click_on "Ny indstilling"

    fill_in "setting_key", with: "ny key"
    fill_in "setting_setable_type", with: @setting.setable_type
    fill_in "setting_setable_id", with: @setting.setable_id
    fill_in "setting_priority", with: @setting.priority
    fill_in "setting_format", with: @setting.format
    fill_in "setting_value", with: @setting.value
    click_on "Opret"

    assert_text "Indstillingen blev oprettet"
  end

  test "should update Setting" do
    visit edit_setting_url(@setting)

    fill_in "setting_key", with: @setting.key
    fill_in "setting_setable_type", with: @setting.setable_type
    fill_in "setting_setable_id", with: @setting.setable_id
    fill_in "setting_priority", with: 4
    fill_in "setting_format", with: @setting.format
    fill_in "setting_value", with: @setting.value
    click_on "Opdatér"

    assert_text "Indstillingen blev opdateret"
  end

  test "should destroy Setting" do
    visit settings_url
    setting_key = settings(:two).key
    setting_li = find("li", text: setting_key)
    within(setting_li) do
      click_on "Open item options", match: :first
      click_on "Slet"
    end
    within("dialog#new_form_modal") do
      assert_text "Slet denne indstilling"
      save_screenshot("test.png")
      click_on "Slet"
    end

    assert_text "Posten blev slettet korrekt"
  end
end
