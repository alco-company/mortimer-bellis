
# <!-- search -->
# <div class="flex flex-1">
#   <form class="flex w-full md:ml-0" action="#" method="GET">
#     <label for="search-field" class="sr-only">Search</label>
#     <div class="relative w-full text-gray-400 focus-within:text-gray-600">
#       <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center" aria-hidden="true">
#         <svg class="size-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon">
#           <path fill-rule="evenodd" d="M9 3.5a5.5 5.5 0 1 0 0 11 5.5 5.5 0 0 0 0-11ZM2 9a7 7 0 1 1 12.452 4.391l3.328 3.329a.75.75 0 1 1-1.06 1.06l-3.329-3.328A7 7 0 0 1 2 9Z" clip-rule="evenodd" />
#         </svg>
#       </div>
#       <input id="search-field" name="search-field" class="block size-full border-transparent py-2 pl-8 pr-3 text-gray-900 focus:border-transparent focus:outline-hidden focus:ring-0 sm:text-sm" placeholder="Search transactions" type="search">
#     </div>
#   </form>
# </div>

class SearchComponent < Phlex::HTML
  attr_accessor :params

  def initialize(params: {})
    @params = params
  end

  def view_template
    search = params.dig(:search) || ""
    form(class: "relative flex flex-1 pt-2", action: "#", method: "GET") do
      label(for: "search-field", class: "sr-only") { "Search" }
      render Icons::Search.new cls: "pointer-events-none absolute top-1 left-0 h-full w-5 text-sky-100"
      input(
        id: "search-field",
        class:
          "block h-full w-full border-0 py-0 pl-8 pr-0 text-gray-900 bg-transparent placeholder:text-sky-100 focus:ring-0 sm:text-sm",
        placeholder: I18n.t("topbar.search.placeholder"),
        type: "search",
        name: "search",
        value: search
      )
    end
  end
end
