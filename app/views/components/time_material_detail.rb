class TimeMaterialDetail < Phlex::HTML
  attr_accessor :items

  def initialize(items:, links: [])
    @items = items
    @links = links
  end

  def view_template
    div(class: "class") do
      div(class: "min-w-full") do
        search_list_item
        # 14/10/2024 removed overflow-hidden from ul.classList in order for context dropdowns on list items to work
        ul(id: "list", role: "list", class: "divide-y divide-gray-100 bg-white") do
          items.each do |item|
            render item.list_item links: [ helpers.edit_time_material_url(item), helpers.time_material_url(item) ], context: @_view_context
          end
        end
      end
    end
  end

  def search_list_item
    ul(id: "search_list", role: "list", class: "bg-white") do
      # search
      li(class: "hidden flex items-center justify-between gap-x-6 px-3 py-5") do
        div(class: "relative flex w-full") do
          input(class: "border border-gray-200 pl-8 rounded-full w-full")
          span(class: "absolute pl-2 -top-2.5") do
            svg(
              class: "text-sky-100 mt-5",
              xmlns: "http://www.w3.org/2000/svg",
              height: "24px",
              viewbox: "0 -960 960 960",
              width: "24px",
              fill: "currentColor"
            ) do |s|
              s.path(
                d:
                  "M784-120 532-372q-30 24-69 38t-83 14q-109 0-184.5-75.5T120-580q0-109 75.5-184.5T380-840q109 0 184.5 75.5T640-580q0 44-14 83t-38 69l252 252-56 56ZM380-400q75 0 127.5-52.5T560-580q0-75-52.5-127.5T380-760q-75 0-127.5 52.5T200-580q0 75 52.5 127.5T380-400Z"
              )
            end
          end
        end
      end
    end
  end
end
