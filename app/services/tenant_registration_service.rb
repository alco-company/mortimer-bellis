class TenantRegistrationService
  attr_reader :destroy
  def self.call(tenant, destroy: false)
    @destroy = destroy
    return remove(tenant) if destroy

    if tenant.persisted?
      pw= Devise.friendly_token[0, 20]
      user = User.create tenant_id: tenant.id, email: tenant.email, role: "admin", password: pw, locale: "da", time_zone: "Europe/Copenhagen", invited_by: Current.user
      if user.valid?
        user.send_confirmation_instructions
        TenantMailer.with(tenant: tenant, pw: pw).welcome.deliver_later
        _team = Team.create tenant: tenant, name: I18n.t("teams.default_team")
        location = Location.create tenant: tenant, name: I18n.t("locations.default_location")
        # User.create tenant: tenant, name: I18n.t("user.me"), pincode: "1234", payroll_employee_ident: "1234", team: team, locale: "da", time_zone: "Europe/Copenhagen"
        PunchClock.create tenant: tenant, name: I18n.t("punch_clocks.user_device_punch_clock"), location: location
        PunchClock.create tenant: tenant, name: I18n.t("punch_clocks.default_punch_clock"), location: location
        return true
      end
    end
    false
  end

  def self.remove(tenant)
    if tenant.persisted?
      UserMailer.with(user: tenant.users.first).last_farewell.deliver if tenant.users.any?
      KillTenantJob.perform_later(tenant: Current.tenant, user: Current.user, t_id: tenant.id)
      return true
    end
    false
  rescue => e
    UserMailer.error_report(e.to_s, "TenantRegistrationService#call - failed for #{tenant&.id} - destroy: #{@destroy ? 'yes' : 'no'}").deliver_later
  end
end
