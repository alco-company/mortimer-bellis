class Employees::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "employee" }) do
      row field(:team_id).select(Team.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_team"), class: "mort-form-text").focus
      row field(:name).input()
      row field(:mugshot).file(class: "mort-form-file")
      row field(:pincode).input()
      row field(:color).select(Team.colors, prompt: I18n.t(".select_team_color"), class: "mort-form-text")
      row field(:punching_absence).boolean(class: "mort-form-bool")
      row field(:email).input()
      row field(:cell_phone).input()
      model.team&.blocked? ?
      (model.blocked = true; row(field(:blocked).boolean(class: "mort-form-bool", disabled: true))) :
      row(field(:blocked).boolean(class: "mort-form-bool"))
      div do
        div(class: "mort-btn-secondary", data: { action: "click->employee#toggleAdvanced" }) { I18n.t("users.advanced_configuration") }
      end if @editable
      div(data: { employee_target: "advanced" }, class: "#{"hidden" if @editable}") do
        row field(:country).input()
        row field(:payroll_employee_ident).input()
        view_only field(:access_token).input()
        row field(:description).input()
        view_only field(:last_punched_at).input()
        row field(:state).select(WORK_STATES, class: "mort-form-text")
        view_only field(:punches_settled_at).date(class: "mort-form-text")
        row field(:job_title).input()
        row field(:birthday).date(class: "mort-form-text")
        row field(:hired_at).input()
        row field(:pbx_extension).input()
        p(class: "text-lg font-medium border-b-2 border-slate-100") { I18n.t("users.contract_template_details") }
        row field(:contract_minutes).input(placeholder: "160:20")
        row field(:contract_days_per_payroll).input(placeholder: "0")
        row field(:contract_days_per_week).input(placeholder: "5")
        row field(:allowed_ot_minutes).input()
        row field(:tmp_overtime_allowed).datetime(class: "mort-form-text")
        row field(:flex_balance_minutes).input()
        row field(:hour_pay).input()
        row field(:ot1_add_hour_pay).input()
        row field(:ot2_add_hour_pay).input()
        row field(:eu_state).input()
        row field(:locale).select(User.locales, prompt: I18n.t(".select_employee_locale"), class: "mort-form-text")
        row field(:time_zone).select(Employee.time_zones_for_phlex, class: "mort-form-text")
      end
    end
  end
end
