require "application_system_test_case"

class EmployeesTest < ApplicationSystemTestCase
  setup do
    login_as users(:one)
    #   @employee = employees(:one)
  end

  test "visiting the index" do
    visit employees_url
    assert_selector "h1", text: "Employees"
  end

  # test "should create employee" do
  #   visit employees_url
  #   click_on "New employee"

  #   fill_in "Access token", with: @employee.access_token
  #   fill_in "Account", with: @employee.account_id
  #   fill_in "Employee ident", with: @employee.employee_ident
  #   fill_in "Last punched at", with: @employee.last_punched_at
  #   fill_in "Name", with: @employee.name
  #   fill_in "Pincode", with: @employee.pincode
  #   fill_in "State", with: @employee.state
  #   fill_in "Team", with: @employee.team_id
  #   click_on "Create Employee"

  #   assert_text "Employee was successfully created"
  #   click_on "Back"
  # end

  # test "should update Employee" do
  #   visit employee_url(@employee)
  #   click_on "Edit this employee", match: :first

  #   fill_in "Access token", with: @employee.access_token
  #   fill_in "Account", with: @employee.account_id
  #   fill_in "Employee ident", with: @employee.employee_ident
  #   fill_in "Last punched at", with: @employee.last_punched_at.to_s
  #   fill_in "Name", with: @employee.name
  #   fill_in "Pincode", with: @employee.pincode
  #   fill_in "State", with: @employee.state
  #   fill_in "Team", with: @employee.team_id
  #   click_on "Update Employee"

  #   assert_text "Employee was successfully updated"
  #   click_on "Back"
  # end

  # test "should destroy Employee" do
  #   visit employee_url(@employee)
  #   click_on "Destroy this employee", match: :first

  #   assert_text "Employee was successfully destroyed"
  # end
end
