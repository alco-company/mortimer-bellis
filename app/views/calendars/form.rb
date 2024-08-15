class Calendars::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "calendar" }) do
      row field(:calendarable_id).hidden
      row field(:calendarable_type).hidden
      row field(:name).input(class: "mort-form-text").focus
    end
  end
end
