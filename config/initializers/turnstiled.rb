Rails.application.config.to_prepare do
  Turnstiled.site_key = "#{ENV.fetch("CLOUDFLARE_TURNSTILE_SITE", nil)}"
  Turnstiled.site_secret = "#{ENV.fetch("CLOUDFLARE_TURNSTILE_SECRET", nil)}"
end
