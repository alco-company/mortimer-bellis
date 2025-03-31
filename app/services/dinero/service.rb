class Dinero::Service < SaasService
  attr_accessor :settings, :provided_service

  def initialize(provided_service: nil, settings: nil, user: Current.get_user)
    Current.system_user = user
    @provided_service = provided_service || Current.get_tenant.provided_services.by_name("Dinero").first || ProvidedService.new
    @settings = settings || @provided_service&.service_params_hash || empty_params
    @settings["organizationId"] = @provided_service.organizationID || 0
  end

  def empty_params
    { "access_token"=> "",
    "refresh_token"=>"",
    "token_type"=>"",
    "scope"=>"",
    "expires_at"=>nil,
    "expires_in"=>3600
    }
  end

  def process(type:, data: {})
    case type
    in :invoice_draft
      return if data[:records].empty? or data[:date].blank?
      Dinero::InvoiceDraft.new(self).process(data[:records], data[:date])
    end
  end

  def auth_url(path)
    return unless Current.get_tenant
    host = "https://connect.visma.com/connect/authorize"
    params = {
      client_id: ENV["DINERO_APP_ID"],
      response_type: "code",
      response_mode: "form_post",
      state: Base64.encode64({ pos_token: Current.get_user.pos_token, path: path }.to_json),
      scope: "dineropublicapi:read dineropublicapi:write offline_access",
      redirect_uri: ENV["DINERO_APP_CALLBACK"]
    }
    "%s?%s" % [ host, params.to_query ]
  end

  def token_fresh?
    result = get "/v1.1/organizations"
    return false if result[:error].present?
    true
  end

  def refresh_token!
    settings["access_token"].nil? ? false : refresh_token
  end

  def get_invoice_settings(code = nil)
    return mocked_settings(code) if Rails.env.test?

    invoice_settings = get "/v1/#{settings["organizationId"]}/sales/settings"
    return {} if invoice_settings[:error].present?
    invoice_settings[:ok].parsed_response
    # rescue => err
    #   UserMailer.error_report(err.to_s, "DineroUpload - Dinero::Service.get_invoice_settings").deliver_later
    #   {}
  end

  def get_creds(creds: {})
    user = User.find_by(pos_token: creds[:pos_token]) rescue nil
    return false if user.nil?

    res = code_to_token(creds[:code])
    if res[:ok].present?
      return { result: true, service_params: res[:ok] }
    end
    { result: false, service_params: res[:error] }
  rescue => e
    { result: false, service_params: { error: e } }
  end

  # list.parsed_response["Pagination"] {"MaxPageSizeAllowed"=>1000, "PageSize"=>100, "Result"=>100, "ResultWithoutFilter"=>428, "Page"=>0}
  # list.parsed_response["Collection"][0] {"Name"=>"13348820", "ContactGuid"=>"cd9f4403-5af3-4815-8fa6-41b15ecaf967", "Street"=>"", "ZipCode"=>"", "City"=>"", "Phone"=>"", "Email"=>"", "VatNumber"=>nil, "EanNumber"=>nil}
  # organizationId = 118244
  # fields = Name,ContactGuid,Street,ZipCode,City,Phone,Email,VatNumber,EanNumber
  # page = 0
  # changesSince = 2015-08-18T06:36:22Z (UTC)
  # pageSize = 100 (max 1000)
  #
  # just_consume = true if we pull from invoice_draft.rb
  #
  def pull(resource_class:, all: false, page: 0, pageSize: 100, fields: nil, status_filter: nil, start_date: nil, end_date: nil, just_consume: false)
    case resource_class.to_s
    when "Customer"; tbl = "contacts"; api_version = "v2"
    when "Product"; tbl = "products"; api_version = "v1"
    when "Invoice"; tbl = "invoices"; api_version = "v1"
    else
      return false
    end
    query = build_query(start_date: start_date, end_date: end_date, all: all, page: page, pageSize: pageSize, fields: fields, status_filter: status_filter)
    list = get "/#{api_version}/#{settings["organizationId"]}/#{tbl}?#{query.to_query}"
    if list[:error].present?
      return false
    end
    return list[:ok] if just_consume

    list[:ok].parsed_response["Collection"].each do |item|
      resource_class.add_from_erp item
    end
    if list[:ok].parsed_response["Pagination"]["ResultWithoutFilter"].to_i > (query[:pageSize].to_i * (query[:page].to_i + 1))
      pull resource_class: resource_class, organizationId: organizationId, all: all, page: query[:page].to_i + 1, pageSize: query[:pageSize].to_i, fields: fields, start_date: start_date, end_date: end_date
    end
    true
  rescue => err
    UserMailer.error_report(err.to_s, "SyncERP - Dinero::Service.pull").deliver_later
    false
  end

  def pull_invoice(guid:)
    invoice = get "/v1/#{settings["organizationId"]}/invoices/#{guid}"
    return {} if invoice[:error].present?
    invoice[:ok]
  end

  def create_invoice(params:)
    return mocked_push_invoice(params) if Rails.env.test?
    invoice = post "/v1/#{settings["organizationId"]}/invoices", params.to_json
    return invoice if invoice[:error].present?
    invoice[:ok]
  end

  def update_invoice(guid:, params:)
    return mocked_push_invoice(params) if Rails.env.test?
    invoice = put "/v1.2/#{settings["organizationId"]}/invoices/#{guid}", params.to_json
    return invoice if invoice[:error].present?
    invoice[:ok]
  end

  private

    # curl --request POST
    # --url https://connect.visma.com/connect/token
    # --header 'content-type: application/x-www-form-urlencoded'
    # --data 'grant_type=authorization_code&redirect_uri=https%3A%2F%2Fdemoapp.example.com/oauthcallback%2Fcallback&code=94c99b73c13c1e39f7b0a7d259628338&client_id=demoapp&client_secret=SECRET'
    #
    # returns
    # res = {
    #   "access_token"=> "eyJhbGciOiJSUzI1NiIsImtpZCI6IjRCQjQzQzg4QzgzODc1MUI3QTI2MDFEMjg0ODFGNEVDOUQwMUExRUJSUzI1NiIsIng1dCI6IlM3UThpTWc0ZFJ0NkpnSFNoSUgwN0owQm9lcyIsInR5cCI6ImF0K0pXVCJ9.eyJpc3MiOiJodHRwczovL2Nvbm5lY3QudmlzbWEuY29tIiwibmJmIjoxNzI3Nzg5OTIyLCJpYXQiOjE3Mjc3ODk5MjIsImV4cCI6MTcyNzc5MzUyMiwiYXVkIjoiaHR0cHM6Ly9hcGkuZGluZXJvLmRrIiwic2NvcGUiOlsiZGluZXJvcHVibGljYXBpOndyaXRlIiwiZGluZXJvcHVibGljYXBpOnJlYWQiLCJvZmZsaW5lX2FjY2VzcyJdLCJhbXIiOlsicHdkbGVzcyIsImZhY2VfZnB0Il0sImNsaWVudF9pZCI6Imlzdl9tb3J0aW1lcl90ZXN0Iiwic3ViIjoiMWYzZWU4MWMtODlhYS00OTg0LWE1MzMtOGNhYWJhNjYxNmJlIiwiYXV0aF90aW1lIjoxNzI3NzcyMjczLCJpZHAiOiJWaXNtYSBDb25uZWN0IiwibGx0IjoxNzI3NzEzMTUyLCJjcmVhdGVkX2F0IjoxNTkyODM2NDkyLCJhY3IiOiIzIiwic2lkIjoiNWU3NzJlMmMtZGZmNC1mZTRjLTQzMzYtM2U0NGU4ZjlhNThmIn0.KQGNfAQiggxzxvx-70wfNufjc6w8kO2ihsUlCLhDXaed0pZlqoJjsBx1s5mO1DCS2x8TgzGsYUodNooIckkoTQaByFFn7AvwnmPKtV3kUcZ2ftR_Qd4tzxG6gG6hZf9PNmOvByMCKTkGHb7C5Y-4g6DXdh-TQ-VXJvUHT3RDdEdN4AszTEz4CC6gsgKhKRS78owg7iXExnGRcGBctnc-owssxyVr1IT7uQ-Aqh2LuIPzlnuxQqsGsWNqlsi29yqOZs-RlJ8J7_HzU8k6Tww4-qnEXVePqvJxSmZBM-U0PyfwLeTkOJhsW_6Nkl8igbjttq1lwA1vsO5qWXnVAjZ5qw",
    #   "expires_in"=>3600,
    #   "token_type"=>"Bearer",
    #   "refresh_token"=>"B5B6AF198B3D7C535D46A4D22F334796E3DA3DE3D62C77FBB67D9CDF04A25AE8",
    #   "scope"=>"dineropublicapi:write dineropublicapi:read offline_access"
    # }
    def code_to_token(code)
      return mocked_run(code) if Rails.env.test?
      # host = "https://localhost:3000/dinero/callback"
      url = "https://connect.visma.com/connect/token"
      headers = { "Content-Type" => "application/x-www-form-urlencoded" }
      params = {
        grant_type: "authorization_code",
        code: code,
        redirect_uri: ENV["DINERO_APP_CALLBACK"],
        client_id: ENV["DINERO_APP_ID"],
        client_secret: ENV["DINERO_APP_SECRET"]
      }

      safe_response "code_to_token", url, headers, "post", params
      # if res["error"].present?
      #   raise "Dinero::Service.code_to_token: %s" % res["error"].to_s
      # end
      # res
    end

    def build_query(start_date: nil, end_date: nil, all:, page:, pageSize:, fields:, status_filter:)
      query = {}
      unless start_date.nil?
        query[:startDate] = start_date
        query[:endDate] = end_date
      end
      query[:changesSince] = resource_class.order(updated_at: :desc).first.updated_at.iso8601 rescue nil
      query.delete(:changesSince) if all
      query[:page] = page
      query[:pageSize] = pageSize
      if fields
        query[:fields] = fields
      end
      if status_filter
        query[:statusFilter] = status_filter
      end
      query
    end

    def get(path, headers = {})
      refresh_token if token_expired? || settings["access_token"].nil?
      headers["Authorization"] = "Bearer %s" % settings["access_token"]

      safe_response "get", "https://api.dinero.dk#{path}", headers
    end

    def post(path, params, headers = {})
      refresh_token if token_expired? || settings["access_token"].nil?
      headers["Authorization"] = "Bearer %s" % settings["access_token"]
      headers["Content-Type"] = "application/json"

      safe_response "post", "https://api.dinero.dk#{path}", headers, "post", params
    end

    def put(path, params, headers = {})
      refresh_token if token_expired? || settings["access_token"].nil?
      headers["Authorization"] = "Bearer %s" % settings["access_token"]
      headers["Content-Type"] = "application/json"

      safe_response "put", "https://api.dinero.dk#{path}", headers, "put", params
    end

    def token_expired?
      Time.now > settings["expires_at"]
    rescue #=> e
      true
    end

    # curl --request POST
    # --url https://connect.visma.com/connect/token
    # --header 'content-type: application/x-www-form-urlencoded'
    # --data 'client_id=isv_demoapp&client_secret=SECRET&grant_type=refresh_token&refresh_token=7990438c99d8158108ab225a4c21f3156ed2b8596a46195ae9fa7c3e88d61e65'
    def refresh_token
      url = "https://connect.visma.com/connect/token"
      headers = { "Content-Type" => "application/x-www-form-urlencoded" }
      params = {
        client_id: ENV["DINERO_APP_ID"],
        client_secret: ENV["DINERO_APP_SECRET"],
        grant_type: "refresh_token",
        refresh_token: settings["refresh_token"]
      }

      res = safe_response "refresh_token", url, headers, "post", params
      if res[:error].present?
        provided_service.update service_params: {}
        return res[:error]
      end
      provided_service.update service_params: res[:ok]
      @settings = provided_service.service_params_hash
      @settings["organizationId"] = provided_service.organizationID
      res[:ok]
    end

    #
    # work="job description"
    # url="https://api.dinero.dk/v1.1/organizations"
    # headers = { "Content-Type" => "application/x-www-form-urlencoded" }
    # method=get
    # params = {}
    #
    # returns:
    #   { ok: res.parsed_response }
    #   { error: code }
    #
    def safe_response(work, url, headers, method = "get", params = {})
      # report_error(work, "", "", url, headers, params, method, "pre-call inspektion")
      res = case method
      when "get"; HTTParty.get(url, headers: headers)
      when "post"; HTTParty.post(url, body: params, headers: headers)
      when "put"; HTTParty.put(url, body: params, headers: headers)
      end
      # report_error(work, res.response.code, res, url, headers, params, method, "pre-call inspektion")

      case true
      when res.response.code.to_i == 200; { ok: res }
      when res.response.code.to_i == 201; { ok: res }
      when res["code"].to_i < 200; report_error(work, res.response.code, res, url, headers, params, method); { error: res }
      else
        report_error(work, res.response.code, res.response, url, headers, params, method)
        { error: res.response.code }
      end
    rescue => err
      UserMailer.error_report(err.to_s, "Dinero::Service.#{work} failed on #{method} with params: #{params} and headers: #{headers}").deliver_later
      { error: err.to_s }
    end

    def report_error(work, code, response = "", url = "", headers = "", params = "", method = "", msg = "failed with code:")
      begin
        Rails.logger.info "------------------------------------"
        Rails.logger.info "Dinero::Service.#{work} - #{msg}"
        Rails.logger.info "code: #{code}"
        Rails.logger.info "response: #{response}"
        Rails.logger.info "url: #{url}"
        Rails.logger.info "headers: #{headers}"
        Rails.logger.info "params: #{params}"
        Rails.logger.info "method: #{method}"
        Rails.logger.info "------------------------------------"
      rescue
      end
      UserMailer.error_report(code, "Dinero::Service.#{work} #{response}").deliver_later
    end

    ### mocked answers for testing

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

    def mocked_settings(code)
      if code == "error"
        { error: "invalid client" }
      else
      {
        "linesInclVat": false,
        "defaultAccountNumber": 1000,
        "invoiceTemplateId": "0e2218cf-2209-4a99-926b-e096382f8ef3",
        "reminderFee": 0,
        "reminderInterestRate": 0,
        "trustPilotEmail": "string"
      }
      end
    end

    def mocked_pull_invoices(contactGuid)
    end

    def mocked_pull_invoice(guid)
      {
        "currency": "DKK",
        "language": "en-GB",
        "externalReference": "Fx. WebshopSpecialId: 42",
        "description": "Description of document type. Fx.: invoice, credit note or offer",
        "comment": "Here is a comment",
        "date": "2022-06-01",
        "productLines": [
          {
            "productGuid": "102eb2e1-d732-4915-96f7-dac83512f16d",
            "description": "Flowers",
            "comments": "Smells good",
            "quantity": 5,
            "accountNumber": 1000,
            "unit": "parts",
            "discount": 10,
            "lineType": "Product",
            "accountName": "Bank",
            "baseAmountValue": 20,
            "baseAmountValueInclVat": 25,
            "totalAmount": 100,
            "totalAmountInclVat": 125
          }
        ],
        "address": "Test Road 3 2300 Copenhagen S Denmark",
        "number": 12,
        "contactName": "My Customer",
        "showLinesInclVat": false,
        "totalExclVat": 200,
        "totalVatableAmount": 200,
        "totalInclVat": 250,
        "totalNonVatableAmount": 0,
        "totalVat": 50,
        "totalLines": [
          {
            "type": "SubTotal",
            "totalAmount": 200,
            "position": 0,
            "label": "Subtotal"
          }
        ],
        "invoiceTemplateId": "0e2218cf-2209-4a99-926b-e096382f8ef3",
        "guid": "ee6a7af7-650d-499b-8e32-58a52ffdb7bc",
        "timeStamp": "00000000020A5EA8",
        "createdAt": "2019-08-24T14:15:22Z",
        "updatedAt": "2019-08-24T14:15:22Z",
        "deletedAt": "2019-08-24T14:15:22Z",
        "status": "Draft",
        "contactGuid": "f8e8286a-9838-46f7-85c6-080dd48b67f4",
        "paymentDate": "2022-06-01",
        "paymentStatus": "Overdue",
        "paymentConditionNumberOfDays": 8,
        "paymentConditionType": "Netto",
        "fikCode": "+71000000016460909+12345678",
        "depositAccountNumber": 55000,
        "mailOutStatus": "Sent, NotSent, Failed, SeenByCustomer",
        "latestMailOutType": "einvoice",
        "isSentToDebtCollection": true,
        "isMobilePayInvoiceEnabled": true,
        "isPensoPayEnabled": true
      }
    end

    def mocked_push_invoice(params)
      if params[:error]
        { error: "invalid client" }
      else
        { "Guid"=> SecureRandom.uuid, "TimeStamp"=> Time.current.iso8601 }
      end
    end
end
