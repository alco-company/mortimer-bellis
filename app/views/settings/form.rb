class Settings::Form < ApplicationForm
  def view_template(&)
    row field(:key).select(Setting.available_keys, class: "mort-form-text").focus
    row field(:setable_type).select(Setting.available_tables, class: "mort-form-text")
    row field(:setable_id).input(class: "mort-form-text")
    row field(:priority).input(class: "mort-form-text")
    row field(:formating).input(class: "mort-form-text")
    row field(:value).input(class: "mort-form-text")
  end
end
