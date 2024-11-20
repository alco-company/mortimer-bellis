class Settings::Form < ApplicationForm
  def view_template(&)
    row field(:key).input(class: "mort-form-text")
    row field(:setable_type).input(class: "mort-form-text").focus
    row field(:setable_id).input(class: "mort-form-text")
    row field(:priority).input(class: "mort-form-text")
    row field(:format).input(class: "mort-form-text")
    row field(:value).input(class: "mort-form-text")
  end
end
