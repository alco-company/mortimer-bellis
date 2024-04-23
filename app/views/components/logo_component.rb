class LogoComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ImageTag  

  def view_template
    logo_image
  end

  def logo_image
    div(class: "absolute left-0 flex-shrink-0 py-5 lg:static") do
      a(href: helpers.root_path) do
        span(class: "sr-only") { "Mortimer Employee App" }
        image_tag "bluewing16by16.svg", class: "h-8 w-auto"
      end
    end    
  end

  def logo_svg
    svg(
      class: "h-8 w-auto text-lime-400",
      data_slot: "icon",
      fill: "none",
      stroke_width: "1.5",
      stroke: "currentColor",
      viewbox: "0 0 24 24",
      xmlns: "http://www.w3.org/2000/svg",
      aria_hidden: "true"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "m20.25 7.5-.625 10.632a2.25 2.25 0 0 1-2.247 2.118H6.622a2.25 2.25 0 0 1-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 0 1.125-.504 1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125Z"
      )
    end
  end

end