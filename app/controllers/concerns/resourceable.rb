module Resourceable
  extend ActiveSupport::Concern

  included do
    def resource_class
      @resource_class ||= params[:controller].split("/").last.classify.constantize
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = params.dig(:id) ? resource_class.find(params[:id]) : resource_class.new
    end

    def set_resources
      @resources = resource_class.all
    end

    def new_resource_url
      url_for(controller: params[:controller], action: :new)
    end

    def resource_url(resource)
      url_for(resource)
    end

    def edit_resource_url(resource)
      url_for(resource) + "/edit"
    end

    def delete_resource_url(resource)
      url_for(resource)
    end

    def resources_url(**options)
      @resources_url ||= url_for(controller: params[:controller], action: :index, **options)
    end
  end
end
