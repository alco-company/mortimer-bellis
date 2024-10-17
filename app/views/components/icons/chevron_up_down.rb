class Icons::ChevronUpDown < Phlex::HTML
  attr_accessor :cls
  def initialize(cls:  "h-5 w-5 text-gray-400")
    @cls = cls
  end

  def view_template
    svg(
      class: cls,
      viewbox: "0 0 20 20",
      fill: "currentColor",
      aria_hidden: "true",
      data_slot: "icon"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M10.53 3.47a.75.75 0 0 0-1.06 0L6.22 6.72a.75.75 0 0 0 1.06 1.06L10 5.06l2.72 2.72a.75.75 0 1 0 1.06-1.06l-3.25-3.25Zm-4.31 9.81 3.25 3.25a.75.75 0 0 0 1.06 0l3.25-3.25a.75.75 0 1 0-1.06-1.06L10 14.94l-2.72-2.72a.75.75 0 0 0-1.06 1.06Z",
        clip_rule: "evenodd"
      )
    end
  end
end
