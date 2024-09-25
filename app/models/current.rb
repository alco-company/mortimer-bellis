class Current < ActiveSupport::CurrentAttributes
  attribute :tenant, :user, :locale

  resets { Time.zone = nil }

  class MissingCurrentTenant < StandardError; end

  def tenant_or_raise!
    return Tenant.first if Rails.env.test?
    raise Current::MissingCurrentTenant, "You must set an tenant with Current.tenant=" unless tenant
    tenant
  end

  def user=(user)
    super
    return unless user.class == User
    self.tenant      = user&.tenant
    self.locale       = user&.locale
    Time.zone         = user&.time_zone
  end
end
