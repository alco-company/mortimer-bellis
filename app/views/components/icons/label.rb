class Icons::Label < Phlex::HTML
  attr_accessor :cls

  def initialize(css: "h-6")
    @cls = css
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor",
      version: "1.1",
      ) { |s|
      s.title { %(ai) }
        s.path(d: "M160-160q-33 0-56.5-23.5T80-240v-480q0-33 23.5-56.5T160-800h440q19 0 36 8.5t28 23.5l216 288-216 288q-11 15-28 23.5t-36 8.5H160Zm0-80h440l180-240-180-240H160v480Zm220-240Z")
      }
  end
end
