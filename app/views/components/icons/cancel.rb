class Icons::Cancel < Phlex::HTML
  def initialize(cls: "h-6 w-6 text-white")
    @cls = cls
  end

  def view_template
svg(
      class: "h-6 w-6 text-white",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      aria_hidden: "true",
      data_slot: "icon"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M6 18 18 6M6 6l12 12"
      )
    end
  end
end
