class Teams::Form < ApplicationForm
  def view_template(&)
    row field(:name).input(class: "mort-form-text").focus
    row field(:team_color).input(class: "mort-form-text")
    row field(:punches_settled_at).date(class: "mort-form-text")
    row field(:locale).input(class: "mort-form-text")
    row field(:time_zone).input(class: "mort-form-text")
  end
end
