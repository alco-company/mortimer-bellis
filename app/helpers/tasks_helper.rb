module TasksHelper
  # def dashboard_task_enable_notifications
  #   render Notifications::EnableNotificationButton.new
  # end

  def dashboard_task_enable_2fa
    # link_to(init_new_user_two_factor_app_url(button_only: true), data: { turbo_stream: true })
    # render TwoFactorField.new button_only: true, dashboard: true, link_only: true
    [ "/auth/edit/2fa/app/init", true ]
  end

  def edit_current_tenant_profile
    [ "/tenants/#{Current.tenant.id}/edit", false ]
  end
end
