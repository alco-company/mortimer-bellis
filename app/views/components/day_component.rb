class DayComponent < CalendarComponent
  def view_template(&block)
    div(class: "flex h-full flex-col") do
      show_header(date)

      div(class: "isolate flex flex-auto overflow-hidden bg-white") do
        div(class: "flex flex-auto flex-col overflow-auto") do
          show_weekday_headers("md:hidden")

          div(class: "flex w-full flex-auto") do
            div(class: "w-14 flex-none bg-white ring-1 ring-gray-100")
            div(class: "grid flex-auto grid-cols-1 grid-rows-1") do
              show_horizontal_lines
              show_events_on_day_and_week({ from: date.to_time, to: date.to_time }, " grid-cols-1")
            end
          end
        end

        # month calendar
        div(class: "hidden w-1/2 max-w-md flex-none border-l border-gray-100 px-8 py-10 md:block") do
          month_component(date.month, true)
        end
      end
    end
  end
end
