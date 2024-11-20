require "test_helper"

class DineroControllerTest < ActionDispatch::IntegrationTest
  test "should get callback" do
    get dinero_callback_url
    assert_response :success
  end
end
