class UserRegistrationService
  def self.call(user, tenant_name)
    if user.persisted?
      tenant = Tenant.find_or_create_by(name: tenant_name, email: user.email)
      team = Team.find_or_create_by tenant: user.tenant, name: I18n.t("teams.default_team")
      user.update tenant: tenant, locale: "da", time_zone: "Europe/Copenhagen", team: team
      location = Location.find_or_create_by tenant: user.tenant, name: I18n.t("locations.default_location")
      PunchClock.find_or_create_by tenant: tenant, name: I18n.t("punch_clocks.user_device_punch_clock"), location: location
      PunchClock.find_or_create_by tenant: tenant, name: I18n.t("punch_clocks.default_punch_clock"), location: location
      UserMailer.with(user: user).welcome.deliver_later
      return true
    end
    false
  rescue => e
    UserMailer.error_report(e.to_s, "Users::RegistrationService#call - failed for #{user&.email}").deliver_later
    false
  end
end
