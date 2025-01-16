class Icons::ChevronUp < Phlex::HTML
  attr_accessor :css, :data
  def initialize(css:  "h-5 w-5 text-gray-400", data: {})
    @css = css
    @data = data
  end

  def view_template
    svg(
      class: css,
      data: data,
      viewbox: "0 -960 960 960",
      fill: "currentColor",
      aria_hidden: "true",
      data_slot: "icon"
    ) do |s|
      s.path(d: "M480-528 296-344l-56-56 240-240 240 240-56 56-184-184Z")
    end
  end
end
