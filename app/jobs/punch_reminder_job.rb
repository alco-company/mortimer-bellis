class PunchReminderJob < ApplicationJob
  queue_as :default

  #
  # args: tenant
  #
  def perform(**args)
    super(**args)
    Current.tenant.users.each do |user|
      user.notify(action: :punch_reminder, title: "Punch Reminder", msg: "Please punch your card")
    end
    # switch_locale(@user.locale) do
    #   user_time_zone(@user.time_zone) do
    #   end
    # rescue => e
    #   say "(switch_locale) PunchJob failed: #{e.message}"
    #   false
    # end
  end
end
