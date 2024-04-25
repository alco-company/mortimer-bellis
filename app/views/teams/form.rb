class Teams::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:team_color).input(class: "mort-form-text").focus
    row field(:locale).input(class: "mort-form-text").focus
    row field(:time_zone).input(class: "mort-form-text").focus
  end
end
