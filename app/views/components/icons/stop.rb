class Icons::Stop < Phlex::HTML
  attr_accessor :cls

  def initialize(css: "h-12")
    @cls = css
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor",
      data: { icon: "stop" }
    ) do |s|
      s.path(
        d: "M320-640v320-320Zm-80 400v-480h480v480H240Zm80-80h320v-320H320v320Z"
      )
    end
  end
end
