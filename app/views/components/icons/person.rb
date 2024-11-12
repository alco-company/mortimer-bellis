class Icons::Person < Phlex::HTML
  attr_accessor :cls, :data

  def initialize(cls: "h-6 text-gray-900 hover:text-gray-500", data: {})
    @cls = cls
    @data = data
  end

  def view_template
    svg(
      class: cls,
      viewbox: "0 0 20 20",
      fill: "currentColor",
      aria_hidden: "true",
      data_slot: "icon",
      data: data
    ) do |s|
      s.path(
        d:
          "M10 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM3.465 14.493a1.23 1.23 0 0 0 .41 1.412A9.957 9.957 0 0 0 10 18c2.31 0 4.438-.784 6.131-2.1.43-.333.604-.903.408-1.41a7.002 7.002 0 0 0-13.074.003Z"
      )
    end
  end
end
