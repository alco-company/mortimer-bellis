# ENV["RAILS_ENV"] ||= "test"
# require_relative "../config/environment"
# require "rails/test_help"

# module ActiveSupport
#   class TestCase
#     # Run tests in parallel with specified workers
#     parallelize(workers: :number_of_processors)

#     # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
#     fixtures :all

#     # Add more helper methods to be used by all tests here...
#     # include Devise::Test::ControllerHelpers
#     include Devise::Test::IntegrationHelpers
#     # include SignInHelper
#   end
# end

# private_key_file = "#{Rails.root}/config/box.mortimer_3-key.pem"
# cert_chain_file = "#{Rails.root}/config/box.mortimer_3.pem"

# Capybara.server = :puma, { Host: "ssl://#{Capybara.server_host}?key=#{private_key_file}&cert=#{cert_chain_file}" }
# Capybara.register_driver :insecure_selenium do |app|
#   Capybara::Selenium::Driver.new(
#     app,
#     browser: :firefox,
#     desired_capabilities: { accept_insecure_certs: true }
#   )
# end

# Capybara.javascript_driver = :insecure_selenium # https://github.com/teamcapybara/capybara#drivers
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "test_helpers/test_password_helper"
#
# NOT WORKING as of 2024-09-13
#

# Error:
# TeamsTest#test_should_create_team:
# NameError: uninitialized constant SignInHelper::Session
#     test/test_helper.rb:10:in `login_via_cookie_as'
#     test/system/teams_test.rb:5:in `block in <class:TeamsTest>'
#
# module SignInHelper
#   def login_via_cookie_as(user)
#     public_session_id = SecureRandom.hex(16)
#     page.driver.set_cookie("session_test", public_session_id, domain: ".example.com", sameSite: :Lax, secure: true, httpOnly: true)
#     private_session_id = Rack::Session::SessionId.new(public_session_id).private_id
#     Session.create!(session_id: private_session_id, data: { user_id: user.id })
#   end
# end
module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    # include Devise::Test::ControllerHelpers
    # include Devise::Test::IntegrationHelpers
    # include SignInHelper
    include TestPasswordHelper
  end
end
