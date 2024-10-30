class Icons::ChevronLeft < Phlex::HTML
  attr_accessor :cls

  def initialize(cls:  "h-5 w-5 text-gray-400", rotated: false)
    cls += " transform rotate-180" if rotated
    @cls = cls
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor",
      aria_hidden: "true",
      data_slot: "icon"
    ) { |s| s.path(d: "M560-240 320-480l240-240 56 56-184 184 184 184-56 56Z") }
  end
end
