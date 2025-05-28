class Mailjet::Service < SaasService
  attr_accessor :settings, :provided_service

  def initialize(provided_service: nil, settings: nil, user: Current.get_user)
    Current.system_user = user
    @provided_service = provided_service || Current.get_tenant.provided_services.by_name("Stripe").first || ProvidedService.new
    @settings = settings || @provided_service&.service_params_hash || empty_params
    @settings = empty_params if @settings["api_key"].blank?
  end

  def empty_params
    { "api_key"=> ENV["MAILERSEND_API_TOKEN"] }
  end

  def send_message
  end
end
