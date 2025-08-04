require "posthog"

module PostHogging
  extend ActiveSupport::Concern

  included do
    before_action :create_posthog_client

    #
    def create_posthog_client
      Current.posthog = PostHog::Client.new({
          api_key: "phc_9G03FF48pq66rNcwQSqiH7aPcsVItkO5n2YMOxzuw5h",
          host: "https://eu.i.posthog.com",
          on_error: Proc.new { |status, msg| print msg }
      }) rescue nil
    end

    def posthog_capture(event: nil, properties: {})
      Current.posthog&.capture({
        distinct_id: (Current.user.id rescue "unknown"),
        event: (event || "#{params[:controller]}_#{params[:action]}" rescue "unknown"),
        properties: properties
      })
    end
  end
end
