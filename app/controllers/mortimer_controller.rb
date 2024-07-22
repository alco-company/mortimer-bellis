class MortimerController < BaseController
  #
  # defined in the resourceable concern
  before_action :set_resource, only: %i[ new show edit update destroy ]
  before_action :set_filter, only: %i[ index destroy ]
  before_action :set_resources, only: %i[ index destroy ]

  include Resourceable
  include DefaultActions
  include TimezoneLocale
end
