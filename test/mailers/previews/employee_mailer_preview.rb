# Preview all emails at http://localhost:3000/rails/mailers/employee_mailer
class EmployeeMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/employee_mailer/report_state
  def report_state
    EmployeeMailer.report_state
  end
end
