module Authorize
  extend ActiveSupport::Concern

  included do
    before_action :authorize
  end

  def authorize
    return true if current_user&.superadmin?
    return true if %W[ dashboards tags tasks time_materials time_material_stats tooltips customers products ].include? params.dig(:controller)

    return true if %w[modal filters filter_fields batches sessions users/sessions users/passwords users/registrations users/confirmations users/otps].include? params.dig(:controller)
    ret = case params.dig(:controller)
    when "editor", "settings", "provided_services"; current_user.admin? ? true : false
    when "projects", "teams"; Current.get_tenant.license == "free" ? false : true
    when "users/invitations"; %(trial ambassador essential pro).include?(Current.get_tenant.license) && current_user.admin? ? true : false
    when "users"; %(trial ambassador essential pro).include?(Current.get_tenant.license) && current_user.admin? ? true : false
    # "invoices", "invoice_items",
    # when "background_jobs", "punches", "punch_clocks", "tasks"; %(ambassador pro).include?(Current.get_tenant.license) ? true : false
    else authorize_controller
    end
    ret ? true : redirect_to(root_path, alert: t(:unauthorized))
  end

  # implement on controller
  def authorize_controller
    false
  end
end
