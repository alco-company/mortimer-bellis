class PunchCards::Form < ApplicationForm
  def view_template(&)
    view_only field("user.name").input(value: model.user.name) if model.user
    row field(:user_id).select(User.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_user"), class: "mort-form-select") unless model.user
    row field(:work_date).date(class: "mort-form-date").focus
    row field(:work_minutes).input()
    row field(:break_minutes).input()
    row field(:ot1_minutes).input()
    row field(:ot2_minutes).input()
  end
end
