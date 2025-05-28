require "test_helper"

class TimeMaterialStatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get time_material_stats_index_url
    assert_response :success
  end
end
