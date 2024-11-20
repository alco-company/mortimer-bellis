class Icons::BackgroundJob < Phlex::HTML
  attr_accessor :cls

  def initialize(cls: "h-6 text-gray-900 hover:text-gray-5000")
    @cls = cls
  end

  def view_template
    svg(
      class: cls,
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 -960 960 960",
      fill: "currentColor",
    ) do |s|
      s.path(
        d:
          "M340-280q25 0 42.5-17.5T400-340q0-25-17.5-42.5T340-400q-25 0-42.5 17.5T280-340q0 25 17.5 42.5T340-280Zm0-280q25 0 42.5-17.5T400-620q0-25-17.5-42.5T340-680q-25 0-42.5 17.5T280-620q0 25 17.5 42.5T340-560Zm280 280q25 0 42.5-17.5T680-340q0-25-17.5-42.5T620-400q-25 0-42.5 17.5T560-340q0 25 17.5 42.5T620-280Zm0-280q25 0 42.5-17.5T680-620q0-25-17.5-42.5T620-680q-25 0-42.5 17.5T560-620q0 25 17.5 42.5T620-560ZM200-120q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h560q33 0 56.5 23.5T840-760v560q0 33-23.5 56.5T760-120H200Zm0-80h560v-560H200v560Zm0-560v560-560Z"
      )
    end
  end
end
