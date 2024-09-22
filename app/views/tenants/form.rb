class Tenants::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:email).input(class: "mort-form-text")
    row field(:tenant_color).select(Tenant.colors, prompt: I18n.t(".select_tenant_color"), class: "mort-form-text")
    row field(:logo).file(class: "mort-form-file")
    row field(:pp_identification).input(class: "mort-form-text")
    row field(:tax_number).input(class: "mort-form-text")
    row field(:locale).select(Tenant.locales, prompt: I18n.t(".select_tenant_locale"), class: "mort-form-text")
    row field(:country).input(class: "mort-form-text")
    row field(:time_zone).select(ActiveSupport::TimeZone.all.collect { |tz| [ "(GMT#{ActiveSupport::TimeZone.seconds_to_utc_offset(tz.utc_offset)}) #{tz.name}", tz.tzinfo.name ] }, class: "mort-form-text")
    # qr_code field(:tenant).input, helpers.resource_url
  end
end
