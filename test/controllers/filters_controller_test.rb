require "test_helper"

class FiltersControllerTest < ActionDispatch::IntegrationTest
  # setup do
  #   @filter = filters(:one)
  #   @params = { filter: { filter_form: "tenants", url: tenants_url(), tenant_id: @filter.tenant.id, filter: @filter.filter, view: @filter.view, submit: "" } }
  # end

  # test "should get index" do
  #   get filters_url
  #   assert_response :success
  # end

  # test "should get new" do
  #   get new_filter_url(url: "/tenants", filter_form: "tenants", format: :turbo_stream, subaction: :refresh)

  #   assert_response :success
  # end

  # test "should create filter" do
  #   assert_difference("Filter.count") do
  #     post filters_url, params: @params
  #   end
  #   assert_redirected_to @params[:filter][:url]
  # end

  # test "should update filter" do
  #   patch filter_url(@filter, format: :turbo_stream, subaction: :refresh), params: @params
  #   assert_redirected_to @params[:filter][:url]
  # end

  # test "should destroy filter" do
  #   assert_difference("Filter.count", -1) do
  #     delete filter_url(@filter), params: @params
  #   end
  #   assert_redirected_to @params[:filter][:url]
  # end
end
