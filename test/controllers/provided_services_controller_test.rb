require "test_helper"

class ProvidedServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provided_service = provided_services(:one)
  end

  test "should get index" do
    get provided_services_url
    assert_response :success
  end

  test "should get new" do
    get new_provided_service_url
    assert_response :success
  end

  test "should create provided_service" do
    assert_difference("ProvidedService.count") do
      post provided_services_url, params: { provided_service: { authorized_by_id: @provided_service.authorized_by_id, name: @provided_service.name, params: @provided_service.params, service: @provided_service.service, tenant_id: @provided_service.tenant_id } }
    end

    assert_redirected_to provided_service_url(ProvidedService.last)
  end

  test "should show provided_service" do
    get provided_service_url(@provided_service)
    assert_response :success
  end

  test "should get edit" do
    get edit_provided_service_url(@provided_service)
    assert_response :success
  end

  test "should update provided_service" do
    patch provided_service_url(@provided_service), params: { provided_service: { authorized_by_id: @provided_service.authorized_by_id, name: @provided_service.name, params: @provided_service.params, service: @provided_service.service, tenant_id: @provided_service.tenant_id } }
    assert_redirected_to provided_service_url(@provided_service)
  end

  test "should destroy provided_service" do
    assert_difference("ProvidedService.count", -1) do
      delete provided_service_url(@provided_service)
    end

    assert_redirected_to provided_services_url
  end
end
