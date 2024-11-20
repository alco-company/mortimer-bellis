require "application_system_test_case"

class EmployeesTest < ApplicationSystemTestCase
  setup do
    login_as users(:one)
    #   @user = employees(:one)
  end

  test "visiting the index" do
    visit employees_url
    assert_selector "h1", text: "Users"
  end

  # test "should create employee" do
  #   visit employees_url
  #   click_on "New employee"

  #   fill_in "Access token", with: @user.access_token
  #   fill_in "Tenant", with: @user.tenant_id
  #   fill_in "User ident", with: @user.user_ident
  #   fill_in "Last punched at", with: @user.last_punched_at
  #   fill_in "Name", with: @user.name
  #   fill_in "Pincode", with: @user.pincode
  #   fill_in "State", with: @user.state
  #   fill_in "Team", with: @user.team_id
  #   click_on "Create User"

  #   assert_text "User was successfully created"
  #   click_on "Back"
  # end

  # test "should update User" do
  #   visit employee_url(@user)
  #   click_on "Edit this employee", match: :first

  #   fill_in "Access token", with: @user.access_token
  #   fill_in "Tenant", with: @user.tenant_id
  #   fill_in "User ident", with: @user.user_ident
  #   fill_in "Last punched at", with: @user.last_punched_at.to_s
  #   fill_in "Name", with: @user.name
  #   fill_in "Pincode", with: @user.pincode
  #   fill_in "State", with: @user.state
  #   fill_in "Team", with: @user.team_id
  #   click_on "Update User"

  #   assert_text "User was successfully updated"
  #   click_on "Back"
  # end

  # test "should destroy User" do
  #   visit employee_url(@user)
  #   click_on "Destroy this employee", match: :first

  #   assert_text "User was successfully destroyed"
  # end
end
