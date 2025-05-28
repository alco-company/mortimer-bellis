require "test_helper"

class BatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get batch_done" do
    get batches_batch_done_url
    assert_response :success
  end
end
