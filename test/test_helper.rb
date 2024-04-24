ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

private_key_file = "#{Rails.root}/config/box.mortimer_3-key.pem"
cert_chain_file = "#{Rails.root}/config/box.mortimer_3.pem"

Capybara.server = :puma, { Host: "ssl://#{Capybara.server_host}?key=#{private_key_file}&cert=#{cert_chain_file}" }
Capybara.register_driver :insecure_selenium do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    desired_capabilities: { accept_insecure_certs: true }
  )
end

Capybara.javascript_driver = :insecure_selenium # https://github.com/teamcapybara/capybara#drivers
