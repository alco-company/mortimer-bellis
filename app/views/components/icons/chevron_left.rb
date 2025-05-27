class Icons::ChevronLeft < Phlex::HTML
  attr_accessor :cls

  def initialize(css:  "h-5 w-5 text-gray-400 ", id: "chevron-left")
    @cls = css
    @id = id
  end

  def view_template
    svg(
      id: @id,
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor",
      height: "16",
      width: "16"
    ) { |s| s.path(d: "M560-240 320-480l240-240 56 56-184 184 184 184-56 56Z") }
  end
end
