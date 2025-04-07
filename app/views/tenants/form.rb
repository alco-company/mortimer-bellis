class Tenants::Form < ApplicationForm
  include Phlex::Rails::Helpers::T

  def view_template(&)
    row field(:name).input().focus, "mort-field", " <span class='text-red-500'>*</span>"
    row field(:email).input(), "mort-field", " <span class='text-red-500'>*</span>"
    row field(:tax_number).input(placeholder: "12345678")
    hr
    row field(:color).select(Tenant.colors, prompt: I18n.t(".select_tenant_color"), class: "mort-form-select")
    row field(:logo).file(class: "mort-form-file")
    # row field(:pp_identification).input()
    row field(:locale).select(Tenant.locales, prompt: I18n.t(".select_tenant_locale"), class: "mort-form-select")
    # row field(:country).input()
    row field(:time_zone).select(Tenant.time_zones_for_phlex, class: "mort-form-select")
    # qr_code field(:tenant).input, helpers.resource_url
    buy_product
    delete_account
  end
end
