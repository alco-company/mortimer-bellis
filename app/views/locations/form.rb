class Locations::Form < ApplicationForm
  def view_template(&)
    row field(:name).input().focus
    row field(:color).select(Location.colors, prompt: I18n.t(".select_location_color"), class: "mort-form-text")
    # row field(:location_color).input()
  end
end
