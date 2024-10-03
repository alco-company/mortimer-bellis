class Current < ActiveSupport::CurrentAttributes
  attribute :tenant, :user, :locale

  resets { Time.zone = nil }

  class MissingCurrentTenant < StandardError; end

  def tenant_or_raise!
    return Tenant.first if Rails.env.test?
    raise Current::MissingCurrentTenant, "You must set an tenant with Current.tenant=" unless tenant
    tenant
  end

  def find_user(user_pos_token)
    Current.user ||= User.find_by(pos_token: user_pos_token) rescue nil
  end

  def find_tenant(tenant_access_token)
    Current.tenant ||= Tenant.find_by(access_token: tenant_access_token) rescue nil
  end

  def user=(user)
    super
    return unless user.class == User
    self.tenant      = user&.tenant
    self.locale       = user&.locale
    Time.zone         = user&.time_zone
  end
end
