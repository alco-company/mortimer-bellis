class EmployeeEuStateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Account.all.each do |account|
      Current.account = account
      Current.user = account.users.order(id: :asc).first rescue nil
      @employees = account.employees
      EmployeeMailer.with(account: account, user: Current.user).report_eu_state.deliver_later
    end
    # Do something later
  end
end
