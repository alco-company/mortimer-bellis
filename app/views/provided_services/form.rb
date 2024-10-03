class ProvidedServices::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:service).input(class: "mort-form-text")
    row field(:service_params).textarea(class: "mort-form-text")
  end
end
