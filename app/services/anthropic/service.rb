class Anthropic::Service < SaasService
  attr_accessor :settings, :provided_service, :anthropic_client

  def initialize(provided_service: nil, settings: nil, user: Current.get_user)
    Current.system_user = user
    @provided_service = provided_service || Current.get_tenant.provided_services.by_name("Anthropic").first || ProvidedService.new
    @settings = settings || @provided_service&.service_params_hash || empty_params
    @settings = empty_params if @settings["api_key"].blank?
  end

  def empty_params
    {
      "api_key": ENV["ANTHROPIC_API_KEY"],
      "model": "claude--3-7-sonnet-latest",
      "max_tokens": 1000,
      "temperature": 0.0,
      "top_k": 0,
      "top_p": 0.0,
      "stop_sequences": [],
      "stream": false,
      "system": "respond in json format"
    }
  end

  def ask(question:)
    client.messages claude_params(question)
  end

  def client
    @anthropic_client ||= Anthropic::Client.new(api_key: settings["api_key"])
  end

  def claude_params(question)
    {
      model: settings["model"],
      system: settings["system"],
      messages: [ { role: "user", content: question } ],
      max_tokens: settings["max_tokens"]
      # temperature: settings["temperature"],
      # top_k: settings["top_k"],
      # top_p: settings["top_p"],
      # stop_sequences: settings["stop_sequences"],
      # stream: settings["stream"],
    }
  end
end
