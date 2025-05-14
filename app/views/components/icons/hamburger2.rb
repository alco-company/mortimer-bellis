class Icons::Hamburger2 < Phlex::HTML
  attr_accessor :cls

  def initialize(css: "size-6")
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
        d: "M3.75 6.75h16.5M3.75 12H12m-8.25 5.25h16.5"
      )
    end
  end
end
