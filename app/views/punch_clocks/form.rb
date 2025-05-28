class PunchClocks::Form < ApplicationForm
  def view_template(&)
    unless model.new_record?
      div(class: "mt-2") do
        helpers.svg_qr_code_link(pos_punch_clock_url(model, api_key: model.access_token))
      end
      link_to(I18n.t("punch_clock.kiosk_ui"), pos_punch_clock_url(model, api_key: model.access_token), class: "mort-pri-link", target: "_blank")
    end

    # view_only field(:access_token).input()

    row field(:name).input().focus
    row field(:location_id).select(Location.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_location"), class: "mort-form-select")
    row field(:ip_addr).input()
    row field(:locale).select(PunchClock.locales, prompt: I18n.t(".select_punch_clock_locale"), class: "mort-form-select")
    row field(:time_zone).select(PunchClock.time_zones_for_phlex, class: "mort-form-select")
  end
end
