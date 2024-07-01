class Calendars::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "calendar" }) do
      row field(:name).input(class: "mort-form-text").focus
    end
  end
end
