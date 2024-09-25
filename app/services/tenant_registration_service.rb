class TenantRegistrationService
  def self.call(tenant)
    if tenant.persisted?
      pw= Devise.friendly_token[0, 20]
      user = User.create tenant_id: tenant.id, email: tenant.email, role: "admin", password: pw, locale: "da", time_zone: "Europe/Copenhagen", invited_by: Current.user
      if user.valid?
        user.send_confirmation_instructions
        TenantMailer.with(tenant: tenant, pw: pw).welcome.deliver_later
        team = Team.create tenant: tenant, name: I18n.t("teams.default_team")
        location = Location.create tenant: tenant, name: I18n.t("locations.default_location")
        # User.create tenant: tenant, name: I18n.t("user.me"), pincode: "1234", payroll_employee_ident: "1234", team: team, locale: "da", time_zone: "Europe/Copenhagen"
        PunchClock.create tenant: tenant, name: I18n.t("punch_clocks.user_device_punch_clock"), location: location
        PunchClock.create tenant: tenant, name: I18n.t("punch_clocks.default_punch_clock"), location: location
      end
    end
  end
end
