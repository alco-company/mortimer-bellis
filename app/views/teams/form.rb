class Teams::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "employee" }) do
      row field(:name).input().focus
      row field(:color).select(Team.colors, prompt: I18n.t(".select_team_color"), class: "mort-form-select")
      view_only field(:punches_settled_at).date(class: "mort-form-date")
      row field(:locale).select(Team.locales, prompt: I18n.t(".select_team_locale"), class: "mort-form-select")
      row field(:time_zone).select(Team.time_zones_for_phlex, class: "mort-form-select")
      row field(:blocked).boolean(class: "mort-form-bool"), "mort-field flex justify-end flex-row-reverse items-center"
      row field(:hourly_rate).input()
      div do
        div(class: "mort-btn-secondary", data: { action: "click->employee#toggleAdvanced" }) { I18n.t("teams.advanced_configuration") }
      end if @editable
      div(data: { employee_target: "advanced" }, class: "#{"hidden" if @editable}") do
        row field(:country).input()
        row field(:payroll_team_ident).input()
        # row field(:state).input()
        row field(:description).textarea(class: "mort-form-text")
        row field(:email).input()
        row field(:cell_phone).input()
        row field(:pbx_extension).input()
        p(class: "text-lg font-medium border-b-2 border-slate-100") { I18n.t("teams.contract_template_details") }
        row field(:contract_minutes).input(placeholder: "160:20")
        row field(:contract_days_per_payroll).input(placeholder: "0")
        row field(:contract_days_per_week).input(placeholder: "5")
        row field(:hour_pay).input()
        row field(:ot1_add_hour_pay).input()
        row field(:ot2_add_hour_pay).input()
        row field(:tmp_overtime_allowed).datetime(class: "mort-form-datetime")
        row field(:eu_state).input()
        row field(:allowed_ot_minutes).input()
      end
    end
  end
end
