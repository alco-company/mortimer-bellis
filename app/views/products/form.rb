class Products::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:product_number).input(class: "mort-form-text")
    row field(:quantity).input(class: "mort-form-text")
    row field(:unit).input(class: "mort-form-text")
    row field(:base_amount_value).input(class: "mort-form-text")
    row field(:account_number).input(class: "mort-form-text")
    row field(:external_reference).input(class: "mort-form-text")
  end
end
