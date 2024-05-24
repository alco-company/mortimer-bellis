class Punches::Form < ApplicationForm
  def view_template(&)
    row field(:employee_id).select(Employee.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_employee"), class: "mort-form-text").focus
    row field(:punch_clock_id).select(PunchClock.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_punch_clock"), class: "mort-form-text")
    row field(:punched_at).datetime(class: "mort-form-text")
    row field(:state).input(class: "mort-form-text")
  end
end
