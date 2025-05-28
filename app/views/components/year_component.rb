class YearComponent < CalendarComponent
  def view_template
    div do
      show_header(date)

      div(class: "bg-white") do
        div(
          class:
            "mx-auto grid max-w-3xl grid-cols-1 gap-x-8 gap-y-16 px-4 py-16 sm:grid-cols-2 sm:px-6 xl:max-w-none xl:grid-cols-3 xl:px-8 2xl:grid-cols-4"
        ) do
          whitespace
          (1..12).each do |month|
            month_component(month)
          end
        end
      end
    end
  end
end
