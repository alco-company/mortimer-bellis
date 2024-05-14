class EmployeeStateJob < ApplicationJob
  queue_as :default

  # params: account
  def perform(**args)
    super(**args)
    switch_locale do
      EmployeeMailer.with(account: Current.account).report_state.deliver_later
    end
  end
end
