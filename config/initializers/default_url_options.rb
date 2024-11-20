Rails.application.routes.default_url_options[:protocol] = "https"
if Rails.env.development?
  Rails.application.routes.default_url_options = {
    host: ENV["WEB_HOST"] || Rails.configuration.action_mailer.default_url_options[:host],
    port: ENV["WEB_PORT"] || Rails.configuration.action_mailer.default_url_options[:port],
    # protocol: Rails.env.production? ? "https" : "http"
    protocol: "https"
  }
end
if Rails.env.production?
  Rails.application.routes.default_url_options = {
    host: ENV["WEB_HOST"] || Rails.configuration.action_mailer.default_url_options[:host],
    protocol: "https"
  }
end
if Rails.env.test?
  Rails.application.routes.default_url_options = {
    host: ENV["WEB_HOST"] || Rails.configuration.action_mailer.default_url_options[:host],
    protocol: "http"
  }
end
