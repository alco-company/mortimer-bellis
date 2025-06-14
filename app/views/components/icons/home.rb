class Icons::Home < Phlex::HTML
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
            "m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"
        )
      end
  end
end
