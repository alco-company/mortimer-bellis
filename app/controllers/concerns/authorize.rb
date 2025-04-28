module Authorize
  extend ActiveSupport::Concern

  included do
    before_action :authorize
  end

  def authorize
    return if current_user&.superadmin?

    return if %w[modal users/sessions users/passwords users/registrations users/confirmations users/otp].include? params.dig(:controller)
    ret = case params.dig(:controller)
    when "dashboards", "time_materials"; true
    # when "background_jobs"; current_user.superadmin? ? true : false
    when "customers", "products", "settings", "provided_services"; current_user.admin? ? true : false
    when "filters", "invoices", "invoice_items", "locations", "projects", "teams"; current_user.admin? && %(ambassador pro).include?(Current.get_tenant.license) ? true : false
    when "users/invitations"; %(ambassador essential pro).include?(Current.get_tenant.license) && current_user.admin? ? true : false
    when "users"; %(ambassador essential pro).include?(Current.get_tenant.license) && current_user.admin? ? true : false
    when "background_jobs", "punches", "punch_clocks", "tasks"; %(ambassador pro).include?(Current.get_tenant.license) ? true : false
    else authorize_controller
    end
    ret ? true : redirect_to(root_path, alert: t(:unauthorized))
  end

  # implement on controller
  def authorize_controller
    false
  end
end
