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
    config.load_defaults 7.2

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

    # require "alco/console" if Rails.env.local? - not working ATM 29/5/2024
    # deprecated solution as of 8.0
    # console do
    #   Rails::ConsoleMethods.send :include, Alco::Console
    #   TOPLEVEL_BINDING.eval("self").extend Alco::Console # PRY
    # end

    # issues with YAML.load_file
    # config.active_record.use_yaml_unsafe_load = true
    # config.active_record.yaml_column_permitted_classes = [
    #   Symbol,
    #   Hash,
    #   Array,
    #   ActiveSupport::TimeWithZone,
    #   ActiveSupport::TimeZone,
    #   ActiveSupport::HashWithIndifferentAccess,
    #   ActiveModel::Attribute.const_get(:FromDatabase),
    #   Time
    # ]
  end
end
