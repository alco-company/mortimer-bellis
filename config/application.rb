require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mortimer
  class Application < Rails::Application
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

    # Noticed notifications configuration
    config.to_prepare do
      Noticed::Event.include Noticed::EventExtensions
      Noticed::Notification.include Noticed::NotificationExtensions
    end
  end
end
