class WeekComponent < CalendarComponent
  def view_template
    div(class: "flex h-full flex-col") do
      show_header(date)

      div(class: "isolate flex flex-auto flex-col overflow-auto bg-white") do
        div(style: "width:165%", class: "flex max-w-full flex-none flex-col sm:max-w-none md:max-w-full") do
          show_weekday_headers()
          show_time_grid()
        end
      end
    end
  end

  def show_time_grid
    div(class: "flex flex-auto") do
      div(class: "hidden sm:block sticky left-0 z-10 w-14 flex-none ring-1 ring-gray-100")
      div(class: "grid flex-auto grid-cols-1 grid-rows-1") do
        show_horizontal_lines("hidden sm:block ")
        show_vertical_lines()
        show_events(" grid-cols-7 sm:pr-8")
      end
    end
  end

  def show_vertical_lines
    div(class: "col-start-1 col-end-2 row-start-1 hidden grid-cols-7 grid-rows-1 divide-x divide-gray-100 sm:grid sm:grid-cols-7") do
      div(class: "col-start-1 row-span-full")
      div(class: "col-start-2 row-span-full")
      div(class: "col-start-3 row-span-full")
      div(class: "col-start-4 row-span-full")
      div(class: "col-start-5 row-span-full")
      div(class: "col-start-6 row-span-full")
      div(class: "col-start-7 row-span-full")
      div(class: "col-start-8 row-span-full w-8")
    end
  end
end
