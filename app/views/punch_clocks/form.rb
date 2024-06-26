class PunchClocks::Form < ApplicationForm
  def view_template(&)
    view_only field(:access_token).input(class: "mort-form-text")
    row field(:name).input(class: "mort-form-text").focus
    row field(:location_id).select(Location.by_account.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_location"), class: "mort-form-text")
    row field(:ip_addr).input(class: "mort-form-text").focus
    row field(:locale).select(PunchClock.locales, prompt: I18n.t(".select_punch_clock_locale"), class: "mort-form-text")
    row field(:time_zone).select(ActiveSupport::TimeZone.all.collect { |tz| [ "(GMT#{ActiveSupport::TimeZone.seconds_to_utc_offset(tz.utc_offset)}) #{tz.name}", tz.tzinfo.name ] }, class: "mort-form-text")
  end
end
