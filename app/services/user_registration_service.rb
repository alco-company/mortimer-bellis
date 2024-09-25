class UserRegistrationService
  def self.call(user, tenant_name)
    if user.persisted?
      tenant = Tenant.find_or_create_by(name: tenant_name, email: user.email).id
      team = Team.create tenant: user.tenant, name: I18n.t("teams.default_team")
      user.update tenant: tenant, locale: "da", time_zone: "Europe/Copenhagen", team: team
      UserMailer.with(user: user).welcome.deliver_later
      location = Location.find_or_create_by tenant: user.tenant, name: I18n.t("locations.default_location")
      # User.create tenant: user.tenant, name: I18n.t("user.me"), pincode: "1234", payroll_employee_ident: "1234", team: team, locale: "da", time_zone: "Europe/Copenhagen"
      PunchClock.create tenant: user.tenant, name: I18n.t("punch_clocks.user_device_punch_clock"), location: location
      PunchClock.create tenant: user.tenant, name: I18n.t("punch_clocks.default_punch_clock"), location: location
    end
  end
end
