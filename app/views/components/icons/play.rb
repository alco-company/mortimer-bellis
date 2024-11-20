class Icons::Play < Phlex::HTML
  attr_accessor :cls

  def initialize(cls: "h-12")
    @cls = cls
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor"
    ) do |s|
      s.path(
        d: "M320-200v-560l440 280-440 280Zm80-280Zm0 134 210-134-210-134v268Z"
      )
    end
  end
end
