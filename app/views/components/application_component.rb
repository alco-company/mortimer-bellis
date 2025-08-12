# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  # temporarily define helpers
  register_value_helper :filtering_url
  register_value_helper :new_modal_url
  register_value_helper :edit_resource_url
  register_value_helper :erp_pull_customers_url
  register_value_helper :erp_pull_products_url
  register_value_helper :erp_pull_invoices_url
  register_value_helper :erp_pull_provided_services_url
  register_value_helper :edit_tenant_path
  register_value_helper :users_invitations_new_url
  register_value_helper :root_path
  register_value_helper :number_to_currency
  register_value_helper :notification_url
  register_output_helper :render


  attr_accessor :params

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  def superadmin
    Current.user&.superadmin?
  end

  def unsafe_raw(html)
    raw(html.html_safe)
  rescue StandardError => e
    Rails.logger.error "Error in unsafe_raw: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def say(msg, level = :info)
    Rails.logger.send(level, "-----------------")
    Rails.logger.send(level, msg)
    Rails.logger.send(level, "-----------------")
  end

  def show_resource_link(resource:, url: nil, turbo_frame: "form", turbo_action: "advance")
    return "" unless resource
    link_to((url || url_for(resource)),
      class: "inline grow flex-nowrap truncate",
      role: "menuitem",
      data: { turbo_action: turbo_action, turbo_frame: turbo_frame },
      tabindex: "-1") do
      resource.name
    end
  end

  def edit_resource_link(resource:, url: nil, turbo_frame: "form")
    link_to((url || edit_resource_url(id: resource.id)),
      class: "block px-3 py-1 text-sm leading-6 text-gray-900",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: turbo_frame },
      tabindex: "-1") do
      plain I18n.t(".edit")
      span(class: "sr-only") do
        plain ", "
        plain resource.name rescue ""
      end
    end
  end


  def new_resource_url(**options)
    url_for(controller: params_ctrl, action: :new, **options)
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
    options[:search] = params_search
    url_for(controller: params_ctrl, action: :index, **options)
  rescue ActionController::UrlGenerationError, NoMethodError => e
    Rails.logger.debug("resources_url fallback for #{params_ctrl}: #{e.message}")
    begin
      url_for(controller: params_ctrl.gsub(/\/.*$/, ""), action: :index)
    rescue
      "/" # final safe fallback
    end
  end

  def resource_class
    @resource_class ||= case params_ctrl&.split("/")&.last
    # when "invitations"; UserInvitation
    when "notifications"; Noticed::Notification
    when "applications"; Doorkeeper::Application
    else; params_ctrl.split("/").last.classify.constantize rescue nil
    end
  end

  def rc_params
    par = params.present? ? params : request_params
    par.respond_to?(:permit) ? par.to_unsafe_h : par
  end

  def request_params
    self.respond_to?(:request) ? request.params : {}
  end

  def params_ctrl
    rc_params.dig(:controller)
  rescue
    debugger
     nil
  end

  def params_s
    rc_params.dig(:s) rescue nil
  end

  def params_d
    rc_params.dig(:d) rescue nil
  end

  def params_parent(ref)
    rc_params.permit(:team_id, :user_id, :tenant_id)[ref] rescue nil
  end

  def params_id
    rc_params[:id] rescue nil
  end

  def params_search
    rc_params.dig(:search) rescue nil
  end
end
