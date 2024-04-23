class MortimerController < ApplicationController
  include Authentication
  include Resourceable
  include DefaultActions
  include TimezoneLocale

  # include Pagy::Backend
end
