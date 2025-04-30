class Icons::Trash < Phlex::HTML
  attr_accessor :cls

  def initialize(cls: "h-6")
    @cls = cls
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor",
      stroke_width: "1.5",
      stroke: "currentColor"
    ) do |s|
      s.title { %(arrows hunting) }
      s.path(
        d:
          "M280-120q-33 0-56.5-23.5T200-200v-520h-40v-80h200v-40h240v40h200v80h-40v520q0 33-23.5 56.5T680-120H280Zm400-600H280v520h400v-520ZM360-280h80v-360h-80v360Zm160 0h80v-360h-80v360ZM280-720v520-520Z"
      )
    end
  end
end
