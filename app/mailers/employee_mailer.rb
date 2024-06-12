class EmployeeMailer < ApplicationMailer
  helper :employees
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.employee_mailer.report_state.subject
  #
  def report_state
    @account = params[:account]
    @employees = @account.employees
    mail to: @account.email, subject: "employee state this morning"
  end

  def report_eu_state
    @account = params[:account]
    @employees = @account.employees
    mail to: @account.email, subject: "employee EU Work Time Directive state this morning"
  end

  def invite
    @invitation = params[:invitation]
    @url = employee_invitation_url(@invitation, api_key: @invitation.access_token)
    @company = "M O R T I M E R"
    @sender = "John Doe"
    mail to: @invitation.address, subject: I18n.t("employee_mailer.invite.subject")
  end

  def confetti_first_punch
    @employee = params[:employee]
    @company = "M O R T I M E R"
    @sender = "John Doe"
    mail to: @employee.email, subject: I18n.t("employee_mailer.confetti_first_punch.subject")
  end
end
