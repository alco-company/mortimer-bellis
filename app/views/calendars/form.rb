class Calendars::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "calendar" }) do
      row field(:name).input().focus
      row field(:calendarable_id).input()
      row field(:calendarable_type).input()
    end
  end
end
