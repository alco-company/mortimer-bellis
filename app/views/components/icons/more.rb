class Icons::More < Phlex::HTML
  def view_template
    svg(
      class: "h-5 w-5",
      viewbox: "0 0 20 20",
      fill: "currentColor",
      aria_hidden: "true"
    ) do |s|
      s.path(
        d:
          "M10 3a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM10 8.5a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM11.5 15.5a1.5 1.5 0 10-3 0 1.5 1.5 0 003 0z"
      )
    end
  end
end
