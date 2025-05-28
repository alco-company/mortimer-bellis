class EditorController < MortimerController
  skip_before_action :set_batch
  skip_before_action :set_resource
  skip_before_action :set_filter
  skip_before_action :set_resources
  skip_before_action :set_resources_stream

  def index
  end
end
