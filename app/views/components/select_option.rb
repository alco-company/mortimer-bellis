class SelectOption < ApplicationComponent
  attr_accessor :field_value, :post

  def initialize(field_value:, post:)
    @field_value = field_value
    @post = post
  end

  def view_template(&block)
    selected = field_value == post.id
    # comment do
    #   %(Combobox option, manage highlight styles based on mouseenter/mouseleave and keyboard navigation. Active: "text-white bg-sky-200", Not Active: "text-gray-900")
    # end
    li(class: "relative cursor-default select-none py-2 pl-3 pr-9 text-gray-900 hover:bg-sky-100 focus:bg-sky-100",
      id: "option-#{post.id}",
      role: "option",
      data: { lookup_target: "item", value: post.id, display_value: post.name, action: "click->lookup#select_option" },
      tabindex: "-1") do
      # comment { %(Selected: "font-semibold") }
      span(class: "#{ selected ? "font-semibold" : "" } block truncate") { post.name }
      # comment do
      #   %(Checkmark, only display for selected option. Active: "text-white", Not Active: "text-sky-200")
      # end
      span(class: "#{ selected ? "" : "hidden" } absolute inset-y-0 right-0 flex items-center pr-4 text-sky-600") do
        render Icons::Checkmark.new
      end
    end
  end
end
