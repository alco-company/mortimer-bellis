require "application_system_test_case"

class ProvidedServicesTest < ApplicationSystemTestCase
  setup do
    @provided_service = provided_services(:one)
  end

  test "visiting the index" do
    visit provided_services_url
    assert_selector "h1", text: "Provided services"
  end

  test "should create provided service" do
    visit provided_services_url
    click_on "New provided service"

    fill_in "Authorized by", with: @provided_service.authorized_by_id
    fill_in "Name", with: @provided_service.name
    fill_in "Params", with: @provided_service.params
    fill_in "Service", with: @provided_service.service
    fill_in "Tenant", with: @provided_service.tenant_id
    click_on "Create Provided service"

    assert_text "Provided service was successfully created"
    click_on "Back"
  end

  test "should update Provided service" do
    visit provided_service_url(@provided_service)
    click_on "Edit this provided service", match: :first

    fill_in "Authorized by", with: @provided_service.authorized_by_id
    fill_in "Name", with: @provided_service.name
    fill_in "Params", with: @provided_service.params
    fill_in "Service", with: @provided_service.service
    fill_in "Tenant", with: @provided_service.tenant_id
    click_on "Update Provided service"

    assert_text "Provided service was successfully updated"
    click_on "Back"
  end

  test "should destroy Provided service" do
    visit provided_service_url(@provided_service)
    click_on "Destroy this provided service", match: :first

    assert_text "Provided service was successfully destroyed"
  end
end
