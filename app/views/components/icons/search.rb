class Icons::Search < Phlex::HTML
  attr_accessor :cls

  def initialize(cls: "pointer-events-none absolute inset-y-0 left-0 h-full w-5 text-gray-400")
    @cls = cls
  end

  def view_template
    svg(
      class: cls,
      viewbox: "0 0 20 20",
      fill: "currentColor",
      # strike: "currentColor",
      aria_hidden: "true",
      data_slot: "icon"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M9 3.5a5.5 5.5 0 1 0 0 11 5.5 5.5 0 0 0 0-11ZM2 9a7 7 0 1 1 12.452 4.391l3.328 3.329a.75.75 0 1 1-1.06 1.06l-3.329-3.328A7 7 0 0 1 2 9Z",
        clip_rule: "evenodd"
      )
    end
  end
end
