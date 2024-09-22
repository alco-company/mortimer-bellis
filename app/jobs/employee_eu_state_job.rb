class EmployeeEuStateJob < ApplicationJob
  queue_as :default

  def perform(**args)
    super(**args)
    switch_locale do
      EmployeeMailer.with(tenant: Current.tenant).report_eu_state.deliver_later
    end
    # Do something later
  end
end
