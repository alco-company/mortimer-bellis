class Calendars::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "calendar" }) do
      row field(:name).input(class: "mort-form-text").focus
      row field(:calendarable_id).input(class: "mort-form-text")
      row field(:calendarable_type).input(class: "mort-form-text")
    end
  end
end
