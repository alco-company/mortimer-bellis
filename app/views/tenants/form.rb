class Tenants::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:email).input(class: "mort-form-text")
    row field(:color).select(Tenant.colors, prompt: I18n.t(".select_tenant_color"), class: "mort-form-text")
    row field(:logo).file(class: "mort-form-file")
    row field(:pp_identification).input(class: "mort-form-text")
    row field(:tax_number).input(class: "mort-form-text")
    row field(:locale).select(Tenant.locales, prompt: I18n.t(".select_tenant_locale"), class: "mort-form-text")
    row field(:country).input(class: "mort-form-text")
    row field(:time_zone).select(Tenant.time_zones_for_phlex, class: "mort-form-text")
    # qr_code field(:tenant).input, helpers.resource_url
  end
end
