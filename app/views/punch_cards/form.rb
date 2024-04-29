class PunchCards::Form < ApplicationForm
  def view_template(&)
    view_only field(:name).input(class: "mort-form-text", value: model.employee.name) if model.employee
    row field(:employee_id).select(Employee.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_employee"), class: "mort-form-text") unless model.employee
    row field(:work_date).date(class: "mort-form-text").focus
    row field(:work_minutes).input(class: "mort-form-text").focus
    row field(:break_minutes).input(class: "mort-form-text").focus
    row field(:ot1_minutes).input(class: "mort-form-text").focus
    row field(:ot2_minutes).input(class: "mort-form-text").focus
  end
end
