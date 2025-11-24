module Resourceable
  extend ActiveSupport::Concern

  attr_reader :resource, :resource_name, :resources, :resource_class, :collection # , :filter, :filter_form, :url

  included do
    def resource
      @resource ||= set_resource
    end

    def resources
      @resources ||= set_resources
    end

    def resource_class
      @resource_class ||= set_resource_class
    end

    def resource_name
      @resource_name ||= resource_class.name.underscore
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = get_resource_id ? find_resource : new_resource
    end

    def new_resource(params = nil)
      params.nil? ? @resource = resource_class.new : @resource = resource_class.new(params)
    end

    def set_resources_stream
      tenant = Current.get_tenant || @resource&.tenant || nil
      @resources_stream ||= tenant.nil? ?
        "1_#{resource_class.to_s.underscore.pluralize}" :
        "%s_%s" % [ tenant&.id, resource_class.to_s.underscore.pluralize ]
    end

    def set_user_resources_stream
      user = Current.get_user || (@resource&.user rescue false) || User.first
      @user_resources_stream ||= "%s_%s" % [ user&.id, resource_class.to_s.underscore.pluralize ]
    end

    def set_resources
      # @resources ||= ResourceableResource.new(resource_class, request.path, params)
      @resources = ResourceableResource.new(resource_class, request.path, params_all, @filter, @batch)
      .parent_or_class
      .filtered
      .batched
      .searched
      .sorted
      .records
    end

    def set_resource_class
      if params_cls.present?
        model = params_cls.classify.constantize
        _m = model.new
      else
        model = case params.dig(:modal_form)
        when "restore_backup"; Tenant
        else nil
        end
      end

      ctrl = params_ctrl&.split("/")&.last
      case ctrl
      when "editor"; User
      when "modal"; model
      when "otps"; User
      when "invitations"; User
      when "passwords"; User
      when "sessions"; User
      when "registrations"; User
      when "confirmations"; User
      when "notifications"; Noticed::Notification
      when "applications"; Oauth::Application
      when "time_material_stats"; TimeMaterial
      else; model || ctrl&.classify&.constantize || (raise "Resource class not found for controller #{ctrl}")
      end
    rescue => e
      if respond_to? :redirect_to
        redirect_to "/", alert: I18n.t("errors.resources.resource_class.not_found", ctrl: (params_ctrl rescue "-"), reason: e.to_s) and return
      end
    end

    def set_filter
      # @filter_form = params_ctrl.split("/").last
      # @filter_form = @filter_form == "modal" ? resource_class.table_name : @filter_form
      @filter_form = resource_class.table_name
      @url = resources_url
      @filter = Filter.by_user.by_view(@filter_form).take || Filter.new
      @filter.filter ||= {}
    end

    def new_resource_url
      build_url_for(controller: params_ctrl, action: :new)
    end

    def resource_url(**options)
      build_url_for(controller: params_ctrl, action: :show, id: @resource.id, **options)
    end

    def copy_resource_url(**options)
      options[:id] = @resource.try(:id) || options.delete(:id)
      build_url_for(controller: params_ctrl, action: :copy, **options)
    rescue
    end

    def edit_resource_url(**options)
      options[:id] = @resource.try(:id) || options.delete(:id)
      build_url_for(controller: params_ctrl, action: :edit, **options)
    rescue
    end

    def delete_resource_url(resource)
      build_url_for(resource)
    end

    #
    # add rewrite: true
    # to skip using the memoized url
    #
    def resources_url(**options)
      options[:search] = params_search if params_search.present?
      build_url_for(controller: params_ctrl, action: :index, **options)
    rescue => e
      Rails.logger.error("Error generating resources_url: #{e.message}")
      root_url
    end

    def filtering_url
      @filter.persisted? ?
        edit_filter_url(@filter, url: resources_url, filter_form: params_ctrl.split("/").last):
        new_filter_url(url: resources_url, filter_form: params_ctrl.split("/").last)
    end

    def delete_all_url
      build_url_for(controller: params_ctrl, id: 1, action: :show, all: true)
    end

    def pos_delete_all_url(date: nil)
      build_url_for(controller: params_ctrl, id: 1, action: :show, all: true, date: date, api_key: @resource.access_token)
    end

    def find_resource
      resource_class.where(id: get_resource_id)&.take || resource_class.new
    rescue
      Rails.logger.info "ERROR! >>>>>>>>>>>>> Resourceable#find_resource: #{params.inspect}"
      redirect_to "/", alert: I18n.t("errors.messages.not_found", model: resource_class.to_s) and return
    end

    def get_resource_id
      params_id
    rescue
      Rails.logger.info "ERROR! >>>>>>>>>>>>> Resourceable#get_resource_id: #{params.inspect}"
      nil
    end
  end

  private
    # def rc_params
    #   params.permit! # (:id, :s, :d, :page, :format, :_method, :commit, :authenticity_token, :controller)
    # end

    def build_url_for controller: nil, action: nil, id: nil, **options
      controller ||= resource_class.to_s.underscore.pluralize
      action ||= :index
      Rails.application.routes.url_helpers.url_for({ controller: controller, action: action, id: id, only_path: false }.merge(options))
    rescue
      root_url
    end

    def params_cls
      params_all.dig :resource_class
    end

    def params_search
      params_all.dig :search
    end

    def params_ctrl
      params_all.dig :controller
    end

    def params_s
      params_all.dig :s
    end

    def params_d
      params_all.dig :d
    end

    # def params_parent(ref)
    #   params.permit(:team_id, :user_id, :tenant_id)[ref]
    # end

    def params_id
      params_all.dig(:id) || params_all.dig(resource_class.to_s.underscore.to_sym, :id)
    end

    def params_all
      return params if params.present?
      {}
    end

    # @resources = any_filters? ? @filter.do_filter(resource_class) : parent_or_class
    # @resources = case resource_class.to_s
    # when "TimeMaterial"; Current.user.can?(:show_all_time_material_posts) ? @resources : @resources.by_user()
    # when "Noticed::Notification"; Current.user.notifications.unread.includes(event: :record)
    # when "Oauth::Application"; @resources
    # else; @resources
    # end
    # @resources = any_sorts? ? @resources.ordered(params_s, params_d) : resource_class.set_order(@resources) rescue @resources
    class ResourceableResource
      attr_accessor :rc, :request_path, :params, :collection, :parent, :filter, :batch

      def initialize(rc, request_path, params, filter = nil, batch = nil)
        @rc = rc
        @request_path = request_path
        @params = params
        @filter = filter
        @batch = batch
        @collection = rc.all
      end

      def parent_or_class
        @collection = parent? ? parent_resources : resource_resources rescue nil
        self
      end

      def filtered
        @collection = @filter.do_filter(rc, collection) if any_filters?
        self
      end

      def batched
        @collection = @batch.entities(collection) if batch&.batch_set?
        self
      end

      def searched
        @collection = params.dig(:search) ? collection.by_fulltext(params.dig(:search)) : collection
        self
      end

      def sorted
        @collection = any_sorts? ? collection.ordered(params.dig(:s), params.dig(:d)) : collection.set_order(collection) rescue collection&.order(id: :desc)
        self
      end

      def records
        @collection
      end

      private

        def resource_resources
          case rc.to_s
          when "TimeMaterial"; Current.user.can?(:show_all_time_material_posts, resource: rc) ? rc.by_tenant() : rc.by_user()
          when "Noticed::Notification"; Current.user.notifications.unread.includes(event: :record)
          when "Oauth::Application"; rc.all
          else; rc.by_tenant
          end
        end

        # "/teams/37/calendars"
        # "/tenants/37/calendars"
        # "/employees/37/calendars"
        # "/calendars/6/events"
        #
        def parent?
          (request_path =~ /\/(team|employee|tenant|calendar)s\/(\d+)\/(calendars|events)/).nil? ? false : true
        end

        #
        # TODO how do we show invoices/11/invoice_items
        def parent_resources
          parent.send params_ctrl
        end

        def parent
          parent_class, parent_id, _ = request_path.scan(/\/(team|employee|tenant|calendar)s\/(\d+)\/(calendars|events)/).first
          @parent ||= parent_class.classify.constantize.find(parent_id)
          # @parent ||= parent_class.find(params_parent(:team_id) || params_parent(:user_id) || params_parent(:tenant_id))
        end

        def parent_class
          parent_class, _, _ = request.path.scan(/\/(team|employee|tenant|calendar)s\/(\d+)\/(calendars|events)/).first
          @parent_class ||= parent_class.classify.constantize
          # @parent_class ||= case request.path.split("/").second
          # when "teams"; Team
          # when "employees"; User
          # when "tenants"; Tenant
          # end
        end

        def any_filters?
          return false if filter.nil? or params.dig(:controller).split("/").last == "filters" or params.dig(:action) == "lookup"
          # !@filter.id.nil?
          filter.persisted?
        end

        def any_sorts?
          params.dig :s
        end
    end
end
