class Session < ApplicationRecord
  belongs_to :user
  has_one :tenant, through: :user

  # mortimer_scoped - override on tables with other tenant scoping association
  scope :mortimer_scoped, ->(ids) { unscoped.where(user_id: ids) } # effectively returns no records

  def self.scoped_for_tenant(id = 1)
    ids = User.where(tenant_id: id).pluck(:id)
    mortimer_scoped(ids)
  end

  enum :authentication_strategy, { password: 0, entraID: 1, otp: 2 }

  def self.check_session_length
    return if Current.user.nil?

    expires_at = last_activity + timeout_duration

    case true
    when Time.now > expires_at; raise MortimerExceptions::SessionExpiredError, "Session has expired"
    when expires_at < 1.hour.since; raise MortimerExceptions::SessionExpiringError, "Session is about to expire"
    when expires_at < 10.minutes.since; raise MortimerExceptions::SessionExpiringSoonError, "Session is expiring soon"
    end
    true
  end

  private
    def self.last_activity
      la = Current.user.last_sign_in_at || Time.current
      raise "Invalid last activity time" unless la.is_a?(ActiveSupport::TimeWithZone)
      la
    rescue
      Time.current
    end

    def self.timeout_duration
      to = Current.tenant.get_session_timeout
      raise "Invalid session timeout" unless to.is_a?(ActiveSupport::Duration) && to > 0
      to
    rescue
      7.days
    end
end
