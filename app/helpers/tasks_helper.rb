module TasksHelper
  def dashboard_task_enable_notifications
    render Notifications::EnableNotificationButton.new
  end

  def dashboard_task_enable_2fa
    render TwoFactorField.new button_only: true, dashboard: true, link_only: true
  end
end
