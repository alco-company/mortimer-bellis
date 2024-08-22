class NotificationsController < MortimerController
  def index
    @notifications = Current.user.notifications
  end
end
