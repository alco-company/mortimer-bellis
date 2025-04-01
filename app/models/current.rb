class Current < ActiveSupport::CurrentAttributes
  attribute :locale, :posthog, :session, :system_user
  delegate :user, to: :session, allow_nil: true
  delegate :tenant, to: :session, allow_nil: true

  # resets { Time.zone = nil }

  # class MissingCurrentTenant < StandardError; end

  # def tenant_or_raise!
  #   return Tenant.first if Rails.env.test?
  #   raise Current::MissingCurrentTenant, "You must set an tenant with Current.tenant=" unless tenant
  #   tenant
  # end

  def notification_stream
    "#{Current.user.id}_noticed/notifications"
  end

  def find_user(user_pos_token)
    Current.system_user ||= User.find_by(pos_token: user_pos_token) rescue nil
  end

  #
  # the get_ methods are used by the jobs
  # and services where no user is logged in and no tenant is set
  # and user and hence tenant is found by the pos_token
  #
  def get_user
    Current.user || Current.system_user
  end

  def get_tenant
    Current.tenant || Current.get_user&.tenant
  end

  # def find_tenant(tenant_access_token)
  #   Current.tenant ||= Tenant.find_by(access_token: tenant_access_token) rescue nil
  # end

  # def posthog=(posthog)
  #   super
  # end

  # def user=(user)
  #   super
  #   return unless user.class == User
  #   self.tenant      = user&.tenant
  #   self.locale       = user&.locale
  #   Time.zone         = user&.time_zone
  # end
end
