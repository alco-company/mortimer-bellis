class Employees::Signup < ApplicationForm
  def view_template(&)
    div(data: { controller: "employee_invitation" }) do
      hidden field(:tenant_id).input(class: "hidden")
      hidden field(:api_key).input(class: "hidden", value: model.access_token)
      hidden field(:team_id).input(class: "hidden")
      view_only field(:team_id).select(Team.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_team"), class: "mort-form-text").focus
      row field(:name).input()
      row field(:birthday).date(class: "mort-form-text")
      row field(:email).input()
      row field(:cell_phone).input()
      row field(:locale).select(User.locales, prompt: I18n.t(".select_employee_locale"), class: "mort-form-text")
      row field(:time_zone).select(ActiveSupport::TimeZone.all.collect { |tz| [ "(GMT#{ActiveSupport::TimeZone.seconds_to_utc_offset(tz.utc_offset)}) #{tz.name}", tz.tzinfo.name ] }, class: "mort-form-text")
      span(id: "user_time_zone", class: "text-sm") { }
    end
  end
end
