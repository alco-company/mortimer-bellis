class Locations::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:location_color).input(class: "mort-form-text")
  end
end
