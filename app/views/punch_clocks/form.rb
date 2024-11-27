class PunchClocks::Form < ApplicationForm
  def view_template(&)
    div(class: "mt-2") do
      helpers.svg_qr_code_link(pos_punch_clock_url(model, api_key: model.access_token))
    end

    link_to("kiosk", pos_punch_clock_url(model, api_key: model.access_token), class: "mort-pri-link", target: "_blank")

    # view_only field(:access_token).input(class: "mort-form-text")
    row field(:name).input(class: "mort-form-text").focus
    row field(:location_id).select(Location.by_tenant.order(name: :asc).select(:id, :name), prompt: I18n.t(".select_location"), class: "mort-form-text")
    row field(:ip_addr).input(class: "mort-form-text").focus
    row field(:locale).select(PunchClock.locales, prompt: I18n.t(".select_punch_clock_locale"), class: "mort-form-text")
    row field(:time_zone).select(PunchClock.time_zones_for_phlex, class: "mort-form-text")
  end
end
