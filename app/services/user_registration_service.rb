class UserRegistrationService
  def self.call(user)
    if user.persisted?
      UserMailer.with(user: user).welcome.deliver_now
      team = Team.create account: user.account, name: I18n.t("teams.default_team")
      location = Location.create account: user.account, name: I18n.t("locations.default_location")
      Employee.create account: user.account, name: I18n.t("employee.me"), pincode: "1234", payroll_employee_ident: "1234", team: team
      PunchClock.create account: user.account, name: I18n.t("punch_clocks.employee_device_punch_clock"), location: location
      PunchClock.create account: user.account, name: I18n.t("punch_clocks.default_punch_clock"), location: location
    end
  end
end
