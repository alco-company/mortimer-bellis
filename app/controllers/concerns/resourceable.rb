module Resourceable
  extend ActiveSupport::Concern

  included do
    def resource_class
      @resource_class ||= case rc_params.split("/").last
      when "invitations"; EmployeeInvitation
      else; rc_params.split("/").last.classify.constantize
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = params_id ? (resource_class.find(params_id) rescue resource_class.new) : resource_class.new
    end

    def set_resources
      @resources = any_filters? ? resource_class.filtered(@filter) : resource_class.by_account()
      @resources = any_sorts? ? resource_class.ordered(@resources, params[:s], params[:d]) : @resources.order(created_at: :desc)
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

    def resource_url(**options)
      url_for(controller: params[:controller], action: :show, id: @resource.id, **options)
    end

    def edit_resource_url(**options)
      options[:id] = @resource.try(:id) || options.delete(:id)
      url_for(controller: params[:controller], action: :edit, **options)
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

    def delete_all_url
      url_for(controller: params[:controller], id: 1, action: :show, all: true)
    end

    def pos_delete_all_url(date: nil)
      url_for(controller: params[:controller], id: 1, action: :show, all: true, date: date, api_key: @resource.access_token)
    end

    def any_filters?
      return false if @filter.nil? or params[:controller].split("/").last == "filters"
      !@filter.id.nil?
    end

    def any_sorts?
      params[:s].present?
    end
  end

  private
    def rc_params
      params.permit(:id, :_method, :commit, :authenticity_token, :controller)[:controller]
    end

    def params_id
      params.permit(:id)[:id]
    end
end
