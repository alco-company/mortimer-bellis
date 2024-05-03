class PunchClockHeader < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  def initialize(resource:, employee: nil)
    @resource = resource
    @employee = employee || false
  end

  def view_template
    div(class: "bg-gray-50 px-4 py-2 sm:px-8 w-full flex flex-row-reverse items-center", data: { punch_clock_target: "offlineWarningHeader" }) do
      div do
        button(data: { action: "click->punch-clock#deleteTap" }, type: "button", class: " inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-10") do
          svg(
            fill: "currentColor",
            stroke_width: "1.5",
            stroke: "currentColor",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24",
            viewbox: "0 -960 960 960",
            width: "24"
          ) do |s|
            s.path(
              d:
                "m256-200-56-56 224-224-224-224 56-56 224 224 224-224 56 56-224 224 224 224-56 56-224-224-224 224Z"
            )
          end
          helpers.t(".close").upcase
        end
      end if @employee
      div(class: "pr-2") do
        h2(class: "uppercase text-xl text-nowrap text-gray-300") { @resource.name rescue "" }
      end
      div(class: "pr-2 flex items-center w-full") do
        span(class: "text-gray-700 text-nowrap text-xl") { @employee&.name }
      end if @employee
      div(class: "hidden text-white mr-10 w-full flex items-center", data: { punch_clock_target: "offlineWarning" }) do
        svg(
          fill: "currentColor",
          stroke_width: "1.5",
          stroke: "currentColor",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24",
          viewbox: "0 -960 960 960",
          width: "24"
        ) do |s|
          s.path(
            d:
              "M84-516 0-600q92-94 215-147t265-53q24 0 48 1.5t48 4.5l-60 116q-12-2-19.5-2H480q-116 0-217.5 43.5T84-516Zm170 170-84-86q56-56 128.5-88.5T456-558l-64 130q-39 12-74 32.5T254-346Zm198 180q-30-11-46.5-41.5T404-268l240-488q4-8 11.5-10.5t16.5.5q8 3 12 10t2 16L556-214q-8 33-40 46.5t-64 1.5Zm254-180q-6-6-13-12t-15-12l32-126q21 15 41.5 30.5T790-432l-84 86Zm170-170q-30-30-64.5-55T738-616l28-120q54 26 103 60t91 76l-84 84Z"
          )
        end

        span(class: "text-white px-4") { helpers.t(".network_not_available") }
      end
    end
  end
end
