class Employees::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "employee" }) do
      row field(:team_id).select(Team.by_account.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_team"), class: "mort-form-text").focus
      row field(:name).input(class: "mort-form-text")
      row field(:mugshot).file(class: "mort-form-file")
      row field(:pincode).input(class: "mort-form-text")
      row field(:punching_absence).boolean(class: "mort-form-bool")
      div do
        div(class: "mort-btn-secondary", data: { action: "click->employee#toggleAdvanced" }) { I18n.t("employees.advanced_configuration") }
      end if @editable
      div(data: { employee_target: "advanced" }, class: "#{"hidden" if @editable}") do
        row field(:payroll_employee_ident).input(class: "mort-form-text")
        view_only field(:access_token).input(class: "mort-form-text")
        row field(:description).input(class: "mort-form-text")
        row field(:email).input(class: "mort-form-text")
        row field(:cell_phone).input(class: "mort-form-text")
        view_only field(:last_punched_at).input(class: "mort-form-text")
        row field(:state).select(WORK_STATES, class: "mort-form-text")
        view_only field(:punches_settled_at).date(class: "mort-form-text")
        row field(:job_title).input(class: "mort-form-text")
        row field(:birthday).date(class: "mort-form-text")
        row field(:hired_at).input(class: "mort-form-text")
        row field(:pbx_extension).input(class: "mort-form-text")
        row field(:contract_minutes).input(class: "mort-form-text")
        row field(:contract_days_per_payroll).input(class: "mort-form-text")
        row field(:contract_days_per_week).input(class: "mort-form-text")
        row field(:allowed_ot_minutes).input(class: "mort-form-text")
        row field(:tmp_overtime_allowed).datetime(class: "mort-form-text")
        row field(:flex_balance_minutes).input(class: "mort-form-text")
        row field(:hour_pay).input(class: "mort-form-text")
        row field(:ot1_add_hour_pay).input(class: "mort-form-text")
        row field(:ot2_add_hour_pay).input(class: "mort-form-text")
        row field(:eu_state).input(class: "mort-form-text")
        row field(:blocked).input(class: "mort-form-text")
        row field(:locale).select(Employee.locales, prompt: I18n.t(".select_employee_locale"), class: "mort-form-text")
        row field(:time_zone).select(ActiveSupport::TimeZone.all.collect { |tz| [ "(GMT#{ActiveSupport::TimeZone.seconds_to_utc_offset(tz.utc_offset)}) #{tz.name}", tz.tzinfo.name ] }, class: "mort-form-text")
      end
    end
  end
end
