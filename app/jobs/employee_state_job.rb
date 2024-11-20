class EmployeeStateJob < ApplicationJob
  queue_as :default

  # params: tenant
  def perform(**args)
    super(**args)
    switch_locale do
      UserMailer.with(tenant: Current.tenant).report_state.deliver_later
    end
  end
end
