class EmployeeInvitations::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "employee_invitation" }) do
      row field(:user_id).select(User.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_user"), class: "mort-form-text").focus
      row field(:team_id).select(Team.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_team"), class: "mort-form-text").focus
      row field(:address).input(class: "mort-form-text", placeholder: I18n.t("user_invitation.address_placeholder"))
      view_only field(:state).select(INVITATION_STATES, prompt: I18n.t(".select_state"), class: "mort-form-text")
    end
  end
end
