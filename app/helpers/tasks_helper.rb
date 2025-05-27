module TasksHelper
  # def dashboard_task_enable_notifications
  #   render Notifications::EnableNotificationButton.new
  # end

  def dashboard_task_enable_2fa
    # link_to(init_new_users_otp_url(button_only: true), data: { turbo_stream: true })
    # render TwoFactorField.new button_only: true, dashboard: true, link_only: true
    [ "/users/otp/new", true ]
  end

  def edit_current_tenant_profile
    [ "/tenants/#{Current.tenant.id}/edit", true ]
  end

  def invite_new_user
    [ "/users/invitations/new", false ]
  end

  def show_products
    [ "/products", false ]
  end
end
