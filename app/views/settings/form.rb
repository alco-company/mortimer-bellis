class Settings::Form < ApplicationForm
  def view_template(&)
    row field(:key).select(Setting.available_keys, class: "mort-form-text").focus
    row field(:setable_type).select(Setting.available_tables, class: "mort-form-text")
    row field(:setable_id).input()
    row field(:priority).input()
    row field(:formating).input()
    row field(:value).input()
  end
end
