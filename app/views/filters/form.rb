class Tenants::Form < ApplicationForm
  def view_template(&)
    row field(:view).input(class: "mort-form-text").focus
    row field(:filter).input(class: "mort-form-text")
  end
end
