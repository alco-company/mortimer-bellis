class Teams::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "employee" }) do
      row field(:name).input(class: "mort-form-text").focus
      row field(:color).select(Team.colors, prompt: I18n.t(".select_team_color"), class: "mort-form-text")
      view_only field(:punches_settled_at).date(class: "mort-form-text")
      row field(:locale).select(Team.locales, prompt: I18n.t(".select_team_locale"), class: "mort-form-text")
      row field(:time_zone).select(ActiveSupport::TimeZone.all.collect { |tz| [ "(GMT#{ActiveSupport::TimeZone.seconds_to_utc_offset(tz.utc_offset)}) #{tz.name}", tz.tzinfo.name ] }, class: "mort-form-text")
      row field(:blocked).boolean(class: "mort-form-bool")
      div do
        div(class: "mort-btn-secondary", data: { action: "click->employee#toggleAdvanced" }) { I18n.t("users.advanced_configuration") }
      end if @editable
      div(data: { employee_target: "advanced" }, class: "#{"hidden" if @editable}") do
        row field(:country).input(class: "mort-form-text")
        row field(:payroll_team_ident).input(class: "mort-form-text")
        # row field(:state).input(class: "mort-form-text")
        row field(:description).textarea(class: "mort-form-text")
        row field(:email).input(class: "mort-form-text")
        row field(:cell_phone).input(class: "mort-form-text")
        row field(:pbx_extension).input(class: "mort-form-text")
        p(class: "text-lg font-medium border-b-2 border-gray-400") { I18n.t("teams.contract_template_details") }
        row field(:contract_minutes).input(class: "mort-form-text", placeholder: "160:20")
        row field(:contract_days_per_payroll).input(class: "mort-form-text", placeholder: "0")
        row field(:contract_days_per_week).input(class: "mort-form-text", placeholder: "5")
        row field(:hour_pay).input(class: "mort-form-text")
        row field(:ot1_add_hour_pay).input(class: "mort-form-text")
        row field(:ot2_add_hour_pay).input(class: "mort-form-text")
        row field(:tmp_overtime_allowed).datetime(class: "mort-form-text")
        row field(:eu_state).input(class: "mort-form-text")
        row field(:allowed_ot_minutes).input(class: "mort-form-text")
      end
    end
  end
end
