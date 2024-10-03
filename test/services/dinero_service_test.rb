require "test_helper"

class DineroServiceTest < ActiveSupport::TestCase
  test "should return auth_url" do
    Current.user = users :no_dinero_authorization

    dinero_service = DineroService.new
    host = "https://connect.visma.com/connect/authorize"
    params = {
      client_id: ENV["DINERO_APP_ID"],
      response_type: "code",
      response_mode: "form_post",
      state: Base64.encode64({ pos_token: Current.user.pos_token }.to_json),
      scope: "dineropublicapi:read dineropublicapi:write offline_access",
      redirect_uri: ENV["DINERO_APP_CALLBACK"]
    }

    url = dinero_service.auth_url
    assert url == "%s?%s" % [ host, params.to_query ]
  end

  test "should return false when tenant is wrong" do
    Current.user = users :no_dinero_authorization

    dinero_service = DineroService.new
    creds = { code: "DA4", pos_token: "wrong!" }
    assert_not dinero_service.get_creds(creds: creds)
  end

  test "should return {} when get_creds is successful" do
    Current.user = users :no_dinero_authorization

    dinero_service = DineroService.new
    creds = { code: "test", pos_token: Current.user.pos_token }
    res = dinero_service.get_creds(creds: creds)
    assert res[:result]
  end

  test "should return false when get_creds is unsuccessful" do
    Current.user = users :no_dinero_authorization

    dinero_service = DineroService.new
    creds = { code: "error", pos_token: Current.user.pos_token }
    res = dinero_service.get_creds(creds: creds)
    assert_not res[:result]
  end

  test "should add service if get_creds is successful" do
    # Current.tenant = tenants :no_dinero_authorization
    Current.user = users :no_dinero_authorization

    assert Current.tenant == Current.user.tenant
    assert Current.tenant.has_service("Dinero") == false
    dinero_service = DineroService.new
    creds = { code: "test", pos_token: Current.user.pos_token }
    res = dinero_service.get_creds(creds: creds)
    assert_difference "ProvidedService.count", 1 do
      dinero_service.add_service("Dinero", res[:service_params])
    end
  end
end
