class SearchComponent < Phlex::HTML
  def view_template
    form(class: "relative flex flex-1", action: "#", method: "GET") do
      label(for: "search-field", class: "sr-only") { "Search" }
      render Icons::Search.new cls: "pointer-events-none absolute inset-y-0 left-0 h-full w-5 text-gray-400"
      input(
        id: "search-field",
        class:
          "block h-full w-full border-0 py-0 pl-8 pr-0 text-gray-900 bg-transparent placeholder:text-gray-400 focus:ring-0 sm:text-sm",
        placeholder: "Search...",
        type: "search",
        name: "search"
      )
    end
  end
end
