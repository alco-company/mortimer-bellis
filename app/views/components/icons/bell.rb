class Icons::Bell < Phlex::HTML
  attr_accessor :cls

  def initialize(css: "h-6 text-gray-900 hover:text-gray-500")
    @cls = css
  end

  def view_template
    svg(
      class: cls,
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      aria_hidden: "true",
      data_slot: "icon"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0"
      )
    end
  end
end
