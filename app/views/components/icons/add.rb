class Icons::Add < Phlex::HTML
  attr_accessor :cls

  def initialize(css: "h-6")
    @cls = css
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor"
    ) do |s|
      s.path(d: "M440-440H200v-80h240v-240h80v240h240v80H520v240h-80v-240Z")
    end
  end
end
