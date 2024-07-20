require "httpx"

module HttpParser
  def self.post_json url, json
    response = HTTPX.post(url, json: json)
    # Rails.logger.debug "------------------------------------ #{ response }"
    response
  end
end