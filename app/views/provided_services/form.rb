class ProvidedServices::Form < ApplicationForm
  def view_template(&)
    row field(:name).input().focus
    row field(:service).input()
    row field(:organizationID).input(placeholder: I18n.t("provided_service.organizationID_placeholder"))
    row field(:product_for_time).input()
    row field(:product_for_overtime).input()
    row field(:product_for_overtime_100).input()
    row field(:product_for_mileage).input()
    row field(:account_for_one_off).input()
    # row field(:product_for_hardware).input()
    hr
    view_only field(:service_params).textarea(class: "mort-form-text"), " overflow-clip max-w-md"
  end
end
