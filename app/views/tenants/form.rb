class Tenants::Form < ApplicationForm
  include Phlex::Rails::Helpers::T

  def view_template(&)
    row field(:name).input().focus
    row field(:tax_number).input(required: true, placeholder: "12345678"), "mort-field", " <span class='text-red-500'>*</span>"
    row field(:email).input(), "mort-field", " <span class='text-red-500'>*</span>"
    hr
    row field(:color).select(Tenant.colors, prompt: I18n.t(".select_tenant_color"), class: "mort-form-select")
    row field(:logo).file(class: "mort-form-file")
    # row field(:pp_identification).input()
    row field(:locale).select(Tenant.locales, prompt: I18n.t(".select_tenant_locale"), class: "mort-form-select")
    # row field(:country).input()
    row field(:time_zone).select(Tenant.time_zones_for_phlex, class: "mort-form-select")
    # qr_code field(:tenant).input, helpers.resource_url
    delete_account
  end

  def delete_account
    if (Current.user.admin? or Current.user.superadmin?) && (Current.user.id > 1)
      div(class: "mt-6 p-4 rounded-md shadow-xs bg-red-100") do
        h2(class: "font-bold text-2xl") { t("users.edit_profile.cancel.title") }
        div do
          p(class: "text-sm") do
            t("users.edit_profile.cancel.unhappy").html_safe
          end
          p do
            link_to(
              new_modal_url(modal_form: "delete_account", id: Current.user.id, resource_class: "user", modal_next_step: "delete_account", url: "/"),
              data: {
                turbo_stream: true
              },
              class: "mort-btn-alert mt-4",
              role: "deleteitem",
              tabindex: "-1"
            ) do
              plain I18n.t(".delete")
              span(class: " sr-only") do
                begin
                  plain resource.name
                rescue StandardError
                  ""
                end
              end
            end
            # = button_to t("users.edit_profile.cancel.action"), registration_path(resource_name), data: { confirm: "Are you sure?", turbo_confirm: "Are you sure?" }, method: :delete, class: "mort-btn-alert mort-field"
          end
        end
      end
    end
  end
end
