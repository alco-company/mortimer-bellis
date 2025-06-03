class EditorController < MortimerController
  skip_before_action :set_batch
  skip_before_action :set_resource
  skip_before_action :set_filter
  skip_before_action :set_resources
  skip_before_action :set_resources_stream

  def index
    @document = params[:document_id] ? Editor::Document.find(params[:document_id]) : nil
    @document ||= Editor::Document.find_or_create_by(tenant: Current.get_tenant, title: "New Document")
  end
end
