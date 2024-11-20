class Holidays::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:countries).input(class: "mort-form-text")
    # row field(:countries).select(Holiday.all_countries, prompt: I18n.t(".select_location_color"), class: "mort-form-text")
    row field(:from_date).date(class: "mort-form-text")
    row field(:to_date).date(class: "mort-form-text")
    row field(:all_day).boolean(class: "mort-form-bool")
  end
end
