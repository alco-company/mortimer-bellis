class Icons::Add < Phlex::HTML
  def view_template
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      class: "h-12 w-12",
      fill: "currentColor",
      stoke: "currentColor"
    ) do |s|
      s.path(d: "M440-440H200v-80h240v-240h80v240h240v80H520v240h-80v-240Z")
    end
  end
end
