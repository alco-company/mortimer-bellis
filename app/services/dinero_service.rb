class DineroService < SaasService
  def auth_url(path)
    return unless Current.tenant
    host = "https://connect.visma.com/connect/authorize"
    params = {
      client_id: ENV["DINERO_APP_ID"],
      response_type: "code",
      response_mode: "form_post",
      state: Base64.encode64({ pos_token: Current.user.pos_token, path: path }.to_json),
      scope: "dineropublicapi:read dineropublicapi:write offline_access",
      redirect_uri: ENV["DINERO_APP_CALLBACK"]
    }
    "%s?%s" % [ host, params.to_query ]
  end

  def get_creds(creds: {})
    user = User.find_by(pos_token: creds[:pos_token]) rescue nil
    return false if user.nil?

    res = code_to_token(creds[:code])
    # res = {
    #   "access_token"=> "eyJhbGciOiJSUzI1NiIsImtpZCI6IjRCQjQzQzg4QzgzODc1MUI3QTI2MDFEMjg0ODFGNEVDOUQwMUExRUJSUzI1NiIsIng1dCI6IlM3UThpTWc0ZFJ0NkpnSFNoSUgwN0owQm9lcyIsInR5cCI6ImF0K0pXVCJ9.eyJpc3MiOiJodHRwczovL2Nvbm5lY3QudmlzbWEuY29tIiwibmJmIjoxNzI3Nzg5OTIyLCJpYXQiOjE3Mjc3ODk5MjIsImV4cCI6MTcyNzc5MzUyMiwiYXVkIjoiaHR0cHM6Ly9hcGkuZGluZXJvLmRrIiwic2NvcGUiOlsiZGluZXJvcHVibGljYXBpOndyaXRlIiwiZGluZXJvcHVibGljYXBpOnJlYWQiLCJvZmZsaW5lX2FjY2VzcyJdLCJhbXIiOlsicHdkbGVzcyIsImZhY2VfZnB0Il0sImNsaWVudF9pZCI6Imlzdl9tb3J0aW1lcl90ZXN0Iiwic3ViIjoiMWYzZWU4MWMtODlhYS00OTg0LWE1MzMtOGNhYWJhNjYxNmJlIiwiYXV0aF90aW1lIjoxNzI3NzcyMjczLCJpZHAiOiJWaXNtYSBDb25uZWN0IiwibGx0IjoxNzI3NzEzMTUyLCJjcmVhdGVkX2F0IjoxNTkyODM2NDkyLCJhY3IiOiIzIiwic2lkIjoiNWU3NzJlMmMtZGZmNC1mZTRjLTQzMzYtM2U0NGU4ZjlhNThmIn0.KQGNfAQiggxzxvx-70wfNufjc6w8kO2ihsUlCLhDXaed0pZlqoJjsBx1s5mO1DCS2x8TgzGsYUodNooIckkoTQaByFFn7AvwnmPKtV3kUcZ2ftR_Qd4tzxG6gG6hZf9PNmOvByMCKTkGHb7C5Y-4g6DXdh-TQ-VXJvUHT3RDdEdN4AszTEz4CC6gsgKhKRS78owg7iXExnGRcGBctnc-owssxyVr1IT7uQ-Aqh2LuIPzlnuxQqsGsWNqlsi29yqOZs-RlJ8J7_HzU8k6Tww4-qnEXVePqvJxSmZBM-U0PyfwLeTkOJhsW_6Nkl8igbjttq1lwA1vsO5qWXnVAjZ5qw",
    #   "expires_in"=>3600,
    #   "token_type"=>"Bearer",
    #   "refresh_token"=>"B5B6AF198B3D7C535D46A4D22F334796E3DA3DE3D62C77FBB67D9CDF04A25AE8",
    #   "scope"=>"dineropublicapi:write dineropublicapi:read offline_access"
    # }
    if res["access_token"]
      return { result: true, service_params: res }
    end
    { result: false, service_params: res }
  rescue => e
    { result: false, service_params: { error: e } }
  end

  def get(path, params = {})
    refresh_token if token_expired?
    HTTParty.get("https://api.dinero.dk#{path}", headers: { "Authorization": "Bearer %s" % Current.tenant.provided_services.by_name("Dinero").first.service_params_hash["access_token"] })
  rescue => e
    debugger
  end

  private

    # curl --request POST
    # --url https://connect.visma.com/connect/token
    # --header 'content-type: application/x-www-form-urlencoded'
    # --data 'grant_type=authorization_code&redirect_uri=https%3A%2F%2Fdemoapp.example.com/oauthcallback%2Fcallback&code=94c99b73c13c1e39f7b0a7d259628338&client_id=demoapp&client_secret=SECRET'
    def code_to_token(code)
      return mocked_run(code) if Rails.env.test?
      # host = "https://localhost:3000/dinero/callback"
      host = "https://connect.visma.com/connect/token"
      params = {
        grant_type: "authorization_code",
        code: code,
        redirect_uri: ENV["DINERO_APP_CALLBACK"],
        client_id: ENV["DINERO_APP_ID"],
        client_secret: ENV["DINERO_APP_SECRET"]
      }

      HTTParty.post(host, body: params, headers: { "Content-Type" => "application/x-www-form-urlencoded" })
    end

    def token_expired?
      Time.now > Current.tenant.provided_services.by_name("Dinero").first.service_params_hash["expires_at"]
    rescue => e
      true
    end

    # curl --request POST
    # --url https://connect.visma.com/connect/token
    # --header 'content-type: application/x-www-form-urlencoded'
    # --data 'client_id=isv_demoapp&client_secret=SECRET&grant_type=refresh_token&refresh_token=7990438c99d8158108ab225a4c21f3156ed2b8596a46195ae9fa7c3e88d61e65'
    def refresh_token
      host = "https://connect.visma.com/connect/token"
      params = {
        client_id: ENV["DINERO_APP_ID"],
        client_secret: ENV["DINERO_APP_SECRET"],
        grant_type: "refresh_token",
        refresh_token: Current.tenant.provided_services.by_name("Dinero").first.service_params_hash["refresh_token"]
      }

      HTTParty.post(host, body: params, headers: { "Content-Type" => "application/x-www-form-urlencoded" })
    end

    def mocked_run(code)
      if code == "error"
        { error: "invalid client" }
      else
        {
          "access_token"=> "eyJhbGciOiJSUzI1NiIsImtpZCI6IjRCQjQzQzg4QzgzODc1MUI3QTI2MDFEMjg0ODFGNEVDOUQwMUExRUJSUzI1NiIsIng1dCI6IlM3UThpTWc0ZFJ0NkpnSFNoSUgwN0owQm9lcyIsInR5cCI6ImF0K0pXVCJ9.eyJpc3MiOiJodHRwczovL2Nvbm5lY3QudmlzbWEuY29tIiwibmJmIjoxNzI3Nzg5OTIyLCJpYXQiOjE3Mjc3ODk5MjIsImV4cCI6MTcyNzc5MzUyMiwiYXVkIjoiaHR0cHM6Ly9hcGkuZGluZXJvLmRrIiwic2NvcGUiOlsiZGluZXJvcHVibGljYXBpOndyaXRlIiwiZGluZXJvcHVibGljYXBpOnJlYWQiLCJvZmZsaW5lX2FjY2VzcyJdLCJhbXIiOlsicHdkbGVzcyIsImZhY2VfZnB0Il0sImNsaWVudF9pZCI6Imlzdl9tb3J0aW1lcl90ZXN0Iiwic3ViIjoiMWYzZWU4MWMtODlhYS00OTg0LWE1MzMtOGNhYWJhNjYxNmJlIiwiYXV0aF90aW1lIjoxNzI3NzcyMjczLCJpZHAiOiJWaXNtYSBDb25uZWN0IiwibGx0IjoxNzI3NzEzMTUyLCJjcmVhdGVkX2F0IjoxNTkyODM2NDkyLCJhY3IiOiIzIiwic2lkIjoiNWU3NzJlMmMtZGZmNC1mZTRjLTQzMzYtM2U0NGU4ZjlhNThmIn0.KQGNfAQiggxzxvx-70wfNufjc6w8kO2ihsUlCLhDXaed0pZlqoJjsBx1s5mO1DCS2x8TgzGsYUodNooIckkoTQaByFFn7AvwnmPKtV3kUcZ2ftR_Qd4tzxG6gG6hZf9PNmOvByMCKTkGHb7C5Y-4g6DXdh-TQ-VXJvUHT3RDdEdN4AszTEz4CC6gsgKhKRS78owg7iXExnGRcGBctnc-owssxyVr1IT7uQ-Aqh2LuIPzlnuxQqsGsWNqlsi29yqOZs-RlJ8J7_HzU8k6Tww4-qnEXVePqvJxSmZBM-U0PyfwLeTkOJhsW_6Nkl8igbjttq1lwA1vsO5qWXnVAjZ5qw",
          "expires_in"=>3600,
          "token_type"=>"Bearer",
          "refresh_token"=>"B5B6AF198B3D7C535D46A4D22F334796E3DA3DE3D62C77FBB67D9CDF04A25AE8",
          "scope"=>"dineropublicapi:write dineropublicapi:read offline_access"
        }
      end
    end
end
