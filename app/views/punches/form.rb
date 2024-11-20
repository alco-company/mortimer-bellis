class Punches::Form < ApplicationForm
  def view_template(&)
    row field(:user_id).select(User.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_user"), class: "mort-form-text").focus
    row field(:punch_clock_id).select(PunchClock.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_punch_clock"), class: "mort-form-text")
    row field(:punched_at).datetime(class: "mort-form-text", required: true)
    row field(:state).select(WORK_STATES, class: "mort-form-text")
    row field(:comment).input(class: "mort-form-text")
  end
end
