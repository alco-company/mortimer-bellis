require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Rails.files [ ".env.development" ] if Rails.env.development?

module Mortimer
  class Application < Rails::Application
    # config.secret_key_base = ENV.fetch("SECRET_KEY_BASE")

    config.autoload_paths << "#{root}/app/views"
    config.autoload_paths << "#{root}/app/views/layouts"
    config.autoload_paths << "#{root}/app/views/components"
    config.autoload_paths << "#{root}/app/views/forms"
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # DEPRECATION WARNING: `to_time` will always preserve the full timezone
    # rather than offset of the receiver in Rails 8.0.
    # To opt in to the new behavior, set `config.active_support.to_time_preserves_timezone = :zone`.
    config.active_support.to_time_preserves_timezone = :zone

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # mission control authentication
    config.mission_control.jobs.base_controller_class = "MortimerController"
    config.mission_control.jobs.http_basic_auth_enabled = false

    # encryption
    config.active_record.encryption.primary_key = ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"]
    config.active_record.encryption.deterministic_key = ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"]
    config.active_record.encryption.key_derivation_salt = ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"]

    # Noticed notifications configuration
    config.to_prepare do
      Noticed::Event.include Noticed::EventExtensions
      Noticed::Notification.include Noticed::NotificationExtensions
    end
  end
end
