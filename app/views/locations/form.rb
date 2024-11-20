class Locations::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:color).select(Location.colors, prompt: I18n.t(".select_location_color"), class: "mort-form-text")
    # row field(:location_color).input(class: "mort-form-text")
  end
end
