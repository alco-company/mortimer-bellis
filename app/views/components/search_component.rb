class SearchComponent < Phlex::HTML
  def view_template
    div(class: "relative flex grow p-2") do
      form(class: "flex flex-1 items-center", action: "#", method: "GET") do
        whitespace
        label(for: "search", class: "sr-only") { "Search" }
        whitespace
        svg(
          class: "absolute pl-2 h-5 text-sky-400 mr-2",
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 -960 960 960",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M784-120 532-372q-30 24-69 38t-83 14q-109 0-184.5-75.5T120-580q0-109 75.5-184.5T380-840q109 0 184.5 75.5T640-580q0 44-14 83t-38 69l252 252-56 56ZM380-400q75 0 127.5-52.5T560-580q0-75-52.5-127.5T380-760q-75 0-127.5 52.5T200-580q0 75 52.5 127.5T380-400Z"
          )
        end
        whitespace
        comment do
          "when not focused: border-0 bg-transparent when focused: mort-form-text"
        end
        whitespace
        input(
          id: "search",
          name: "search",
          type: "search",
          class:
            "border-0 bg-transparent -mt-0.5 pl-7 placeholder:text-sm placeholder:text-gray-400",
          placeholder: "search ..."
        )
      end
    end
  end
end
