class Icons::Download < Phlex::HTML
  attr_accessor :cls

  def initialize(cls: "h-6")
    @cls = cls
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor"
    ) do |s|
      s.path(
        d:
          "M480-320 280-520l56-58 104 104v-326h80v326l104-104 56 58-200 200ZM240-160q-33 0-56.5-23.5T160-240v-120h80v120h480v-120h80v120q0 33-23.5 56.5T720-160H240Z"
      )
    end
  end
end
