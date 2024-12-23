class LogoComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ImageTag

  #
  # logo can be a boolean or a string
  # if it is a string, it is the path to the image
  # if it is a boolean, it is false = no logo
  # if no args are passed, it will default to mortimer logo
  #
  def initialize(**attribs)
    @logo = attribs[:logo].present? ? attribs[:logo] : "mortimer"
    @root = attribs[:root] || nil
    @div_css = attribs[:div_css] || "relative left-0 pl-2 flex-shrink-0 py-5 lg:static"
  end

  def view_template
    logo_image
    # show_version
  end

  def logo_image
    unless @logo
      div { }
    else
      div(class: @div_css) do
        a(href: @root || helpers.root_path) do
          span(class: "sr-only") { "Mortimer User App" }
          if @logo == "mortimer"
            mortimer_svg
          else
            image_tag @logo, class: "h-8 w-auto"
          end
        end
      end
    end
  end

  def show_version
    mc = superadmin ? "text-pink-400" : "text-mortimer"
    div(class: "absolute top-[5px] #{mc} text-xs font-thin") { ENV["MORTIMER_VERSION"] }
  end

  def mortimer_svg
    mc = superadmin ? "text-pink-400" : "text-mortimer"
    svg(
      class: "h-8 w-auto #{mc}",
      xmlns: "http://www.w3.org/2000/svg",
      width: "16",
      height: "16",
      viewBox: "0 0 16 16",
      stroke: "none",
      fill: "currentColor",
      # fill: "#1f9cd8",
      title: "Mortimer Capital M"
    ) do |s|
      s.path(
        d: "M.72,11.3A7,7,0,0,1,.44,9a14.83,14.83,0,0,1,.67-4.5,1.37,1.37,0,0,1,.54-.77,1.89,1.89,0,0,1,1-.25,1,1,0,0,1,.51.09.38.38,0,0,1,.15.35A7,7,0,0,1,3.08,5.2q-.18.73-.29,1.27A12.63,12.63,0,0,0,2.61,7.8,9.86,9.86,0,0,1,3.78,5.4a5.54,5.54,0,0,1,1.4-1.47,2.47,2.47,0,0,1,1.36-.48,1.18,1.18,0,0,1,.9.29,1.3,1.3,0,0,1,.26.89,11.58,11.58,0,0,1-.35,2.11q-.15.66-.2,1a9,9,0,0,1,2-3.26,3.21,3.21,0,0,1,2.08-1,1,1,0,0,1,1.19,1.18A14.7,14.7,0,0,1,12,7.2a12.68,12.68,0,0,0-.35,2.1q0,.73.53.73a1.42,1.42,0,0,0,.87-.45,14.65,14.65,0,0,0,1.34-1.45.64.64,0,0,1,.49-.25.42.42,0,0,1,.37.22,1.13,1.13,0,0,1,.14.6,1.68,1.68,0,0,1-.35,1.13,8,8,0,0,1-1.69,1.59,3.53,3.53,0,0,1-2.05.62,1.77,1.77,0,0,1-1.4-.54,2.29,2.29,0,0,1-.47-1.56,11.31,11.31,0,0,1,.25-1.82A9.45,9.45,0,0,0,10,6.53q0-.29-.2-.29t-.67.61a9,9,0,0,0-.87,1.61,13.14,13.14,0,0,0-.71,2.11A2.78,2.78,0,0,1,7,11.74,1.09,1.09,0,0,1,6.2,12a1,1,0,0,1-.9-.57A3,3,0,0,1,5,10.06a15.79,15.79,0,0,1,.18-2q.15-1.17.15-1.53t-.2-.29q-.27,0-.69.66a9.46,9.46,0,0,0-.81,1.68,16.08,16.08,0,0,0-.63,2,2.85,2.85,0,0,1-.47,1.16,1,1,0,0,1-.83.3A1,1,0,0,1,.72,11.3Z"
      )
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
