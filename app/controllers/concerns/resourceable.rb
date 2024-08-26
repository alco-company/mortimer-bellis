module Resourceable
  extend ActiveSupport::Concern

  attr_reader :resource, :resources # , :filter, :filter_form, :url

  included do
    def resource
      @resource ||= set_resource
    end

    def resources
      @resources ||= set_resources
    end

    def resource_class
      @resource_class ||= case params_ctrl.split("/").last
      when "invitations"; EmployeeInvitation
      else; params_ctrl.split("/").last.classify.constantize rescue nil
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = params_id ? (resource_class.find(params_id) rescue resource_class.new) : resource_class.new
    end

    def set_resources
      @resources_stream = "%s_%s" % [ Current.account.id, resource_class.to_s.underscore.pluralize ]
      @resources = any_filters? ? resource_class.filtered(@filter) : parent_or_class
      @resources = any_sorts? ? resource_class.ordered(@resources, params_s, params_d) : @resources.order(created_at: :desc) rescue nil
    end

    def parent_or_class
      parent? ? parent_resources : resource_class.by_account() rescue nil
    end

    # "/teams/37/calendars"
    # "/accounts/37/calendars"
    # "/employees/37/calendars"
    # "/calendars/6/events"
    #
    def parent?
      (request.path =~ /\/(team|employee|account|calendar)s\/(\d+)\/(calendars|events)/).nil? ? false : true
    end

    def parent_resources
      parent.send params_ctrl
    end

    def parent
      parent_class, parent_id, _ = request.path.scan(/\/(team|employee|account|calendar)s\/(\d+)\/(calendars|events)/).first
      @parent ||= parent_class.classify.constantize.find(parent_id)
      # @parent ||= parent_class.find(params_parent(:team_id) || params_parent(:employee_id) || params_parent(:account_id))
    end

    def parent_class
      parent_class, _, _ = request.path.scan(/\/(team|employee|account|calendar)s\/(\d+)\/(calendars|events)/).first
      @parent_class ||= parent_class.classify.constantize
      # @parent_class ||= case request.path.split("/").second
      # when "teams"; Team
      # when "employees"; Employee
      # when "accounts"; Account
      # end
    end

    def set_filter
      @filter_form = params_ctrl.split("/").last
      @url = resources_url
      @filter = Filter.where(account: Current.account).where(view: params_ctrl.split("/").last).take || Filter.new
      @filter.filter ||= {}
    end

    def new_resource_url
      url_for(controller: params_ctrl, action: :new)
    end

    def resource_url(**options)
      url_for(controller: params_ctrl, action: :show, id: @resource.id, **options)
    end

    def edit_resource_url(**options)
      options[:id] = @resource.try(:id) || options.delete(:id)
      url_for(controller: params_ctrl, action: :edit, **options)
    rescue
    end

    def delete_resource_url(resource)
      url_for(resource)
    end

    def resources_url(**options)
      @resources_url ||= url_for(controller: params_ctrl, action: :index, **options)
    end

    def filtering_url
      new_filter_url(url: resources_url, filter_form: params_ctrl.split("/").last)
    end

    def delete_all_url
      url_for(controller: params_ctrl, id: 1, action: :show, all: true)
    end

    def pos_delete_all_url(date: nil)
      url_for(controller: params_ctrl, id: 1, action: :show, all: true, date: date, api_key: @resource.access_token)
    end

    def any_filters?
      return false if @filter.nil? or params_ctrl.split("/").last == "filters"
      !@filter.id.nil?
    end

    def any_sorts?
      params[:s].present?
    end
  end

  private
    def rc_params
      params.permit(:id, :s, :d, :_method, :commit, :authenticity_token, :controller)
    end

    def params_ctrl
      rc_params[:controller]
    end

    def params_s
      rc_params[:s]
    end

    def params_d
      rc_params[:d]
    end

    def params_parent(ref)
      params.permit(:team_id, :employee_id, :account_id)[ref]
    end

    def params_id
      rc_params[:id]
    end
end
