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
    @user = params[:user]
    mail to: @account.email, subject: "employee state this morning"
  end

  def report_eu_state
    @account = params[:account]
    @employees = @account.employees
    @user = params[:user]
    mail to: @account.email, subject: "employee EU Work Time Directive state this morning"
  end
end
