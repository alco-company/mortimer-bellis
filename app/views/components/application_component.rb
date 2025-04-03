# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

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

  def say(msg, level = :info)
    Rails.logger.send(level, "-----------------")
    Rails.logger.send(level, msg)
    Rails.logger.send(level, "-----------------")
  end

  def show_resource_link(item)
    link_to(url_for(item),
      class: "inline grow flex-nowrap truncate",
      role: "menuitem",
      data: { turbo_action: "advance", turbo_frame: "form" },
      tabindex: "-1") do
      item.name
    end if item
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
    options[:search] = params.expect(:search) if params[:search].present?
    url_for(controller: params_ctrl, action: :index, **options)
  end

  def resource_class
    @resource_class ||= case params_ctrl.split("/").last
    # when "invitations"; UserInvitation
    when "notifications"; Noticed::Notification
    when "applications"; Doorkeeper::Application
    else; params_ctrl.split("/").last.classify.constantize rescue nil
    end
  end

  def rc_params
    params.respond_to?(:permit) ? params.permit! : params
    # params.permit(:id, :s, :d, :page, :format, :_method, :commit, :authenticity_token, :controller)
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
    params.permit(:team_id, :user_id, :tenant_id)[ref]
  end

  def params_id
    rc_params[:id]
  end
end
