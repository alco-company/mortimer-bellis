class EmployeeMailer < ApplicationMailer
  helper :employees

  def welcome
    @employee = params[:employee]
    @tenant = @employee.tenant
    @url = pos_employee_url(@employee, api_key: @employee.access_token)
    @sender = params[:sender]
    mail to: @employee.email, subject: I18n.t("employee_mailer.welcome.subject")
  end

  def pos_link
    @employee = params[:employee]
    @tenant = @employee.tenant
    @url = pos_employee_url(@employee, api_key: @employee.access_token)
    @sender = params[:sender]
    mail to: @employee.email, subject: I18n.t("employee_mailer.pos_link.subject")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.employee_mailer.report_state.subject
  #
  def report_state
    @tenant = params[:tenant]
    @employees = @tenant.employees
    mail to: @tenant.email, subject: "employee state this morning"
  end

  def report_eu_state
    @tenant = params[:tenant]
    @employees = @tenant.employees
    mail to: @tenant.email, subject: "employee EU Work Time Directive state this morning"
  end

  def invite
    @invitation = params[:invitation]
    @url = employee_invitation_url(@invitation, api_key: @invitation.access_token)
    @company = @invitation.tenant.name
    @email = @invitation.address
    @sender = @inviter = params[:sender]
    mail to: @email, subject: I18n.t("employee_mailer.invite.subject")
  end

  def confetti_first_punch
    @employee = params[:employee]
    @name = @employee.name
    @company = @employee.tenant.name
    @sender = "info@mortimer.pro"
    mail to: @employee.email, subject: I18n.t("employee_mailer.confetti.subject")
  end
end
