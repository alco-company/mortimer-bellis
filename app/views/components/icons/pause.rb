class Icons::Pause < Phlex::HTML
  attr_accessor :cls

  def initialize(css: "h-12")
    @cls = css
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor",
      data: { icon: "pause" }
    ) do |s|
      s.path(d: "M520-200v-560h240v560H520Zm-320 0v-560h240v560H200Zm400-80h80v-400h-80v400Zm-320 0h80v-400h-80v400Zm0-400v400-400Zm320 0v400-400Z")
    end
  end
end
