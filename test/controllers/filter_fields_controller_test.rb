require "test_helper"

class FilterFieldsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get filter_fields_new_url
    assert_response :success
  end

  test "should get create" do
    get filter_fields_create_url
    assert_response :success
  end

  test "should get show" do
    get filter_fields_show_url
    assert_response :success
  end
end
