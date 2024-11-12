class ProvidedServices::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:service).input(class: "mort-form-text")
    row field(:organizationID).input(class: "mort-form-text", placeholder: I18n.t("provided_service.organizationID_placeholder"))
    row field(:product_for_time).input(class: "mort-form-text")
    row field(:product_for_overtime).input(class: "mort-form-text")
    row field(:product_for_overtime_100).input(class: "mort-form-text")
    row field(:product_for_mileage).input(class: "mort-form-text")
    row field(:account_for_one_off).input(class: "mort-form-text")
    # row field(:product_for_hardware).input(class: "mort-form-text")
    hr
    view_only field(:service_params).textarea(class: "mort-form-text"), " overflow-clip max-w-md"
  end
end
