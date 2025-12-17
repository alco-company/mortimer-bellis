class Icons::Copy < Phlex::HTML
  attr_accessor :cls

  def initialize(css: "h-6 text-gray-900 hover:text-gray-500")
    @cls = css
  end

  def view_template
    svg(
      class: cls,
      fill: "currentColor",
      viewbox: "0 -960 960 960",
      aria_hidden: "true",
      data_slot: "icon"
    ) do |s|
      s.path(
        d:
          "M360-240q-33 0-56.5-23.5T280-320v-480q0-33 23.5-56.5T360-880h360q33 0 56.5 23.5T800-800v480q0 33-23.5 56.5T720-240H360Zm0-80h360v-480H360v480ZM200-80q-33 0-56.5-23.5T120-160v-560h80v560h440v80H200Zm160-240v-480 480Z"
      )
    end
  end
end
