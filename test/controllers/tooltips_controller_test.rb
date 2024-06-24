require "test_helper"

class TooltipsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get tooltips_show_url
    assert_response :success
  end
end
