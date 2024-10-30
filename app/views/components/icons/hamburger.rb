class Icons::Hamburger < Phlex::HTML
  attr_accessor :cls

  def initialize(cls: "h-12 w-12")
    @cls = cls
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
        d: "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
      )
    end
  end
end
