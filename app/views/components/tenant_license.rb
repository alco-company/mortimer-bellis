class TenantLicense < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  def view_template
    # return unless Current.get_user.admin? or Current.get_user.superadmin?
    turbo_frame_tag "tenant_license" do
      p(class: "text-sm text-purple-600") do
        t("users.edit_profile.buy_product.current_status", license: license_title).html_safe
      end
      p(class: "text-xs text-purple-600") do
        t("users.edit_profile.buy_product.license_expiring", expiring: license_ex).html_safe
      end
      p(class: "text-xs text-purple-600") do
        t("users.edit_profile.buy_product.license_changed", changed: license_changed).html_safe
      end

      if Current.get_tenant.license_expires_shortly? or %W[trial free].include? Current.get_tenant.license
        p do
          link_to(
            new_modal_url(modal_form: "buy_product", id: Current.get_tenant.id, resource_class: "tenant", modal_next_step: "pick_product", url: "/"),
            data: {
              turbo_stream: true
            },
            class: "mort-btn-primary hover:bg-purple-500 bg-purple-600 mt-4",
            role: "buyitem",
            tabindex: "-1"
          ) do
            plain t("users.edit_profile.buy_product.manage_status")
            span(class: " sr-only") do
              begin
                plain resource.name
              rescue StandardError
                ""
              end
            end
          end
        end
      end
    end
  end

  def license_title
    "Mortimer #{Current.get_tenant.license&.titleize}"
  rescue
    "N/A"
  end

  def license_ex
    l(Current.get_tenant.license_expires_at, format: :short)
  rescue
    "N/A"
  end

  def license_changed
    l(Current.get_tenant.license_changed_at, format: :short)
  rescue
    "N/A"
  end
end
