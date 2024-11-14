class MortimerController < BaseController
  #
  # defined in the resourceable concern
  before_action :set_resource, only: %i[ new show edit update destroy ]
  before_action :set_filter, only: %i[ index destroy ]
  before_action :set_resources, only: %i[ index destroy ]
  before_action :set_resources_stream

  include Resourceable
  include DefaultActions
  include TimezoneLocale

  #
  # called by models that have a mugshot
  # on create and update actions
  #
  def resize_before_save(image_param, width, height)
    return unless image_param

    begin
      ImageProcessing::MiniMagick
        .source(image_param)
        .resize_to_fit(width, height)
        .call(destination: image_param.tempfile.path)
    rescue StandardError => _e
      # Do nothing. If this is catching, it probably means the
      # file type is incorrect, which can be caught later by
      # model validations.
    end
  end
end
