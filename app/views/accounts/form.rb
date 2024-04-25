class Accounts::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:email).input(class: "mort-form-text")
    row field(:pp_identification).input(class: "mort-form-text")
    row field(:locale).input(class: "mort-form-text")
    row field(:time_zone).input(class: "mort-form-text")
    # qr_code field(:account).input, helpers.resource_url
  end
end
