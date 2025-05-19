require "test_helper"
require "test_helpers/capybara_setup"
require "test_helpers/cuprite_helpers"
require "test_helpers/cuprite_setup"
require "test_helpers/phlex_helpers"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite, using: :chromium, screen_size: [ 1400, 1400 ], options: {
    js_errors: true,
    slowmo: ENV["SLOWMO"]&.to_f
   }

  # include Warden::Test::Helpers
  include CupriteHelpers
  include PhlexHelpers
end
