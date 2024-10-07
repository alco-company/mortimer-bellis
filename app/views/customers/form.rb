class Customers::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:street).input(class: "mort-form-text")
    row field(:zipcode).input(class: "mort-form-text")
    row field(:city).input(class: "mort-form-text")
    row field(:phone).input(class: "mort-form-text")
    row field(:email).input(class: "mort-form-text")
    row field(:vat_number).input(class: "mort-form-text")
    row field(:ean_number).input(class: "mort-form-text")
  end
end
