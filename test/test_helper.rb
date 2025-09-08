ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "test_helpers/test_password_helper"
require "capybara/rails"

module ActiveSupport
  class TestCase
    # Disable parallelization temporarily to stabilize system tests
    # parallelize(workers: :number_of_processors)
    fixtures :all
    include TestPasswordHelper
  end
end
