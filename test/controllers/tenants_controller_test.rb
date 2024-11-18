require "test_helper"

class TenantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Current.tenant = tenants(:one)
    @tenant = tenants(:one)
    sign_in users(:one)
  end

  test "should get index" do
    get tenants_url
    assert_response :success
  end

  test "should get new" do
    get new_tenant_url
    assert_response :success
  end

  # t.string "name"
  # t.string "email"
  # t.string "pp_identification"
  # t.string "locale"
  # t.string "time_zone"
  # t.string "send_state_rrule"
  # t.string "send_eu_state_rrule"
  # t.string "color"
  # t.string "tax_number"
  # t.string "country"
  test "should create tenant" do
    assert_difference("Tenant.count") do
      get tenants_url
      assert_response :success
      post tenants_url, params: { tenant: { email: @tenant.email, locale: @tenant.locale, country: "DK", color: "green", tax_number: "12345678", name: @tenant.name, pp_identification: @tenant.pp_identification, time_zone: @tenant.time_zone } }
      assert_response :success
    end
    # assert_redirected_to tenants_url()
  end

  test "should show tenant" do
    get tenant_url(@tenant)
    assert_response :success
  end

  test "should get edit" do
    get edit_tenant_url(@tenant)
    assert_response :success
  end

  test "should update tenant" do
    sign_in users(:one)
    patch tenant_url(@tenant), params: { tenant: { email: @tenant.email, locale: @tenant.locale, name: @tenant.name, pp_identification: @tenant.pp_identification, time_zone: @tenant.time_zone } }
    assert_response :success
    # assert_redirected_to tenants_url()
  end

  test "should destroy tenant" do
    assert_difference("Tenant.count", -1) do
      delete tenant_url(@tenant)
    end

    assert_redirected_to tenants_url
  end
end
