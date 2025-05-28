class Icons::Filter < Phlex::HTML
  attr_accessor :cls

  def initialize(css: "h-6 text-gray-900 hover:text-gray-500")
    @cls = css
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor",
    ) do |s|
      s.path(
        d:
          "M400-240v-80h160v80H400ZM240-440v-80h480v80H240ZM120-640v-80h720v80H120Z"
      )
    end
  end
end
