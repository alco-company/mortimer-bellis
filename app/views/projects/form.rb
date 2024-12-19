class Projects::Form < ApplicationForm
  def view_template(&)
    row field(:name).input().focus
    row field(:customer_id).select(Customer.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_customer"), class: "mort-form-text")
    row field(:description).input()
    row field(:start_date).datetime(class: "mort-form-text", required: true)
    row field(:end_date).datetime(class: "mort-form-text", required: true)
    row field(:state).select(Project.project_states, class: "mort-form-text")
    row field(:budget).input()
    row field(:is_billable).boolean(class: "mort-form-bool")
    row field(:is_separate_invoice).boolean(class: "mort-form-bool")
    row field(:hourly_rate).input()
    row field(:priority).input()
    row field(:estimated_minutes).input()
    row field(:actual_minutes).input()
  end
end
