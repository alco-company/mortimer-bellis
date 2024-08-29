module Noticed::NotificationExtensions
  extend ActiveSupport::Concern

  included do
    after_save_commit :broadcast_changes

    def broadcast_changes
      broadcast_update_to_bell
      broadcast_replace_notifications
    end
  end

  def broadcast_update_to_bell
    broadcast_replace_later_to(
      "#{recipient.id}_noticed/notifications",
      target: "notification_bell",
      partial: "notifications/bell",
      locals: { recipient: recipient }
    )
  end

  def broadcast_replace_notifications
    broadcast_replace_later_to(
      "#{recipient.id}_noticed/notifications",
      target: "notifications",
      partial: "notifications/notifications",
      locals: { recipient: recipient }
    )
  end

  def broadcast_replace_to_index_count
    # broadcast_replace_to(
    #   "notifications_index_#{recipient.id}",
    #   target: "notification_index_count",
    #   partial: "notifications/notifications_count",
    #   locals: { count: recipient.reload.notifications_count, unread: recipient.reload.unread_notifications_count }
    # )
  end

  def broadcast_prepend_to_index_list
    broadcast_prepend_to(
      "#{recipient.id}_noticed/notifications",
      target: "notifications",
      partial: "notifications/notification",
      locals: { notification: self }
    )
  end
end
