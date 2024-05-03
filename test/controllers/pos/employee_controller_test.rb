require "test_helper"

class Pos::EmployeeControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get pos_employee_show_url
    assert_response :success
  end

  test "should get edit" do
    get pos_employee_edit_url
    assert_response :success
  end

  test "should get index" do
    get pos_employee_index_url
    assert_response :success
  end

  test "should get create" do
    get pos_employee_create_url
    assert_response :success
  end
end
