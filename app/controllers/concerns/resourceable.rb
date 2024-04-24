module Resourceable
  extend ActiveSupport::Concern

  included do
    def resource_class
      @resource_class ||= params.permit![:controller].split("/").last.classify.constantize
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = params.dig(:id) ? resource_class.find(params[:id]) : resource_class.new
      if %w[employee punch].include? resource_class.to_s.downcase
        @resource.state = "OUT" if @resource.state.nil?
      end
    end

    def set_resources
      @resources = any_filters? ? resource_class.filtered(@filter) : resource_class.all
    end

    def set_filter
      @filter_form = params[:controller].split("/").last
      @url = resources_url
      @filter = Filter.where(account: Current.account).where(view: params[:controller].split("/").last).take || Filter.new
      @filter.filter ||= {}
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

    def filtering_url
      new_filter_url(url: resources_url, filter_form: params[:controller].split("/").last)
    end

    def any_filters?
      return false if @filter.nil? or params[:controller].split("/").last == "filters"
      !@filter.id.nil?
    end
  end
end
