class Icons::Microsoft < Phlex::HTML
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
      s.path(fill: "#f3f3f3", d: "M0 0h23v23H0z")
      s.path(fill: "#f35325", d: "M1 1h10v10H1z")
      s.path(fill: "#81bc06", d: "M12 1h10v10H12z")
      s.path(fill: "#05a6f0", d: "M1 12h10v10H1z")
      s.path(fill: "#ffba08", d: "M12 12h10v10H12z")
    end
  end
end
