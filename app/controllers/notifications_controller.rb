class NotificationsController < MortimerController
  def show
    @resource.read? ? mark_unread : mark_read
    head :ok
  end

  def index
    # @notifications = Current.user.notifications.unread.includes(event: :record).newest_first
    ActiveRecord::Base.connected_to(role: :writing) { Current.user.notifications.unseen.mark_as_seen }
  end

  private

    # override resourceable concern b/c this stream has to be unique to the user
    def set_resources_stream
      @resources_stream = Current.notification_stream
    end

    def mark_unread
      @resource.mark_as_unread
    end

    def mark_read
      @resource.mark_as_read
      Turbo::StreamsChannel.broadcast_remove_to @resources_stream, target: dom_id(@resource)
    end
end
