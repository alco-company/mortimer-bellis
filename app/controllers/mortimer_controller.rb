class MortimerController < BaseController
  # defined in the authorize concern
  before_action :authorize
  #
  # defined in the batch_actions concern
  before_action :set_batch, only: %i[ new index destroy] # new b/c of modal
  #
  # defined in the resourceable concern
  before_action :set_resource, only: %i[ new show edit update destroy ]
  before_action :set_filter, only: %i[ new index destroy ] # new b/c of modal
  before_action :set_resources, only: %i[ index destroy ]
  before_action :set_resources_stream

  include Authorize
  include Resourceable
  include BatchActions
  include DefaultActions
  include TimezoneLocale

  layout :resolve_layout

  def resolve_layout
    return "application" if params[:controller] =~ /password/
    case params[:action]
    when "edit"; "edit"
    else; "application"
    end
  end

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
