class Icons::Play < Phlex::HTML
  def view_template
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      class: "h-12 w-12",
      fill: "currentColor",
      stoke: "currentColor"
    ) do |s|
      s.path(
        d: "M320-200v-560l440 280-440 280Zm80-280Zm0 134 210-134-210-134v268Z"
      )
    end
  end
end
