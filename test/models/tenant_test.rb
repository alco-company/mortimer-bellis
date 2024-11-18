require "test_helper"

class TenantTest < ActiveSupport::TestCase
  test "should verify that provided service exists" do
    Current.user = users :one

    assert_not Current.tenant.has_service("Dinero")
    dinero_service = Dinero::Service.new
    creds = { code: "test", access_token: Current.user.pos_token }
    res = dinero_service.get_creds(creds: creds)
    dinero_service.add_service("Dinero", res[:service_params])
    assert Current.tenant.has_service("Dinero")
  end

  test "should verify that provided access_token is correct" do
    Current.tenant = tenants :no_dinero_authorization
    assert Current.tenant.has_this_access_token("12345678")
  end
end
