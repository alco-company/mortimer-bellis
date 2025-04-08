class ApplicationForm < Superform::Rails::Form
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::TurboFrameTag
  include FieldSpecializations
  include FormSpecializations

  attr_accessor :resource, :cancel_url, :title, :edit_url,  :editable, :api_key, :model, :fields

  def initialize(resource:, editable: nil, **options)
    options[:data] ||= { form_target: "form" }
    options[:class] ||= "mort-form"
    super(resource, **options)
    @resource = @model = resource
    @fields = options[:fields] || []
    @fields = @fields.any? ? @fields : model.class.attribute_types.keys
    @editable = editable
    @api_key = options[:api_key] || ""
  end

  def view_template(&)
    form_fields fields: fields
  end

  class Phlex::SGML
    def format_object(object)
      case object.class.to_s
      when "ActiveSupport::TimeWithZone"; object.strftime("%d-%m-%y")
      when "Array"; object.map { |o| format_object(o) }.join(", ")
      when "Date"; object.strftime("%Y-%m-%d")
      when "DateTime"; object.strftime("%Y-%m-%d %H:%M:%S")
      when "Decimal", "BigDecimal", "Float", "Integer"; object.to_s
      when "Phlex::SGML::Decimal"; object.to_s
      when "FalseClass"; I18n.t(:no)
      when "TrueClass"; I18n.t(:yes)
      when "NilClass"; ""
      else; object
      end
    rescue => err
      UserMailer.error_report(err.to_s, "Phlex::SGML format_object error with object #{ object.class }").deliver_later
    end
  end

  def buy_product
    div(class: "mt-6 p-4 rounded-md shadow-xs bg-purple-100") do
      h2(class: "font-bold text-2xl text-purple-800") { t("users.edit_profile.buy_product.title") }
      if Current.user.superadmin?
        row field(:license).enum_select(Tenant.licenses.keys, class: "mort-form-select")
        row field(:license_expires_at).date(class: "mort-form-date"), "mort-field my-0"
        row field(:license_changed_at).date(class: "mort-form-date"), "mort-field my-0"
      end
      render TenantLicense.new
    end
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
