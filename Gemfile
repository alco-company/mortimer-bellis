source "https://rubygems.org"

# in Ruby 3.3.3 net-pop is broken
gem "net-pop", github: "ruby/net-pop"

# Use main development branch of Rails
gem "rails", github: "rails/rails", branch: "main"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
gem "tailwindcss-ruby", "4.1.11"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable", github: "wdiechmann/solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.14"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "amazing_print"

  gem "dotenv-rails"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # gem "rails_live_reload"
  gem "hotwire-spark", "~> 0.1.13"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  # gem "selenium-webdriver"
  gem "cuprite", "~> 0.15.1"
end

gem "phlex-rails"

gem "superform", "~> 0.5.0"

gem "pagy", "~> 9.0"

gem "rqrcode", "~> 2.2"

gem "activerecord-enhancedsqlite3-adapter", "~> 0.8.0"

gem "get_process_mem", "~> 1.0.0"

gem "redcarpet", "~> 3.6"

gem "httparty", "~> 0.23.1"

gem "psych", "~> 5.2.0"

gem "rrule", "~> 0.6.0"

gem "httpx", "~> 1.4"

gem "mission_control-jobs", "~> 0.6.0"

gem "noticed", "~> 2.4"

gem "x", "~> 0.14.1"

gem "omniauth", "~> 2.1"
gem "omniauth-entra-id", "~> 3.0"
gem "omniauth-rails_csrf_protection", "~> 1.0"

gem "web-push", "~> 3.0"

gem "doorkeeper", "~> 5.8"

gem "posthog-ruby", "~> 3.0"

gem "active_model_otp"

gem "stripe", "~> 15.1"

gem "anthropic", "~> 0.4.0"

# gem "mailjet", "~> 1.8"

gem "mailersend-ruby", "~> 3.0"

# gem "turnstiled", "~> 0.1.14"

gem "positioning"
