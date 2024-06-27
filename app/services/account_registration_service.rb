class AccountRegistrationService
  def self.call(account)
    if account.persisted?
      pw= Devise.friendly_token[0, 20]
      user = User.create account_id: account.id, email: account.email, role: "admin", password: pw, locale: "da", time_zone: "Europe/Copenhagen", invited_by: Current.user
      if user.valid?
        user.send_confirmation_instructions
        AccountMailer.with(account: account, pw: pw).welcome.deliver_later
        team = Team.create account: account, name: I18n.t("teams.default_team")
        location = Location.create account: account, name: I18n.t("locations.default_location")
        Employee.create account: account, name: I18n.t("employee.me"), pincode: "1234", payroll_employee_ident: "1234", team: team, locale: "da", time_zone: "Europe/Copenhagen"
        PunchClock.create account: account, name: I18n.t("punch_clocks.employee_device_punch_clock"), location: location
        PunchClock.create account: account, name: I18n.t("punch_clocks.default_punch_clock"), location: location
      end
    end
  end
end
