class ToggleButton < ApplicationComponent
  #
  def initialize(resource:, label: "toggle", url: nil, params: {})
    @resource = resource
    @label = label
    @url = url
    @params = params
    @toggled_on = @params[:template].present? ? @params[:template] == "off" : false
  end

  def view_template
    comment { %(Enabled: "bg-indigo-600", Not Enabled: "bg-gray-200") }
    button(
      type: "button",
      data: { toggle_button_target: "toggle", action: "click->toggle-button#toggle" },
      class:
        "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent #{ @toggled_on ? "bg-indigo-600" : "bg-gray-200" } transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2",
      role: "switch",
      aria_checked: @toggled_on ? "true" : "false",
      aria_labelledby: "annual-billing-label"
    ) do
      comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
      span(
        data: { toggle_button_target: "toggleSpan" },
        aria_hidden: "true",
        class:
          "pointer-events-none inline-block h-5 w-5 translate-x-0 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
      )
    end

    span(class: "ml-3 text-sm", id: "annual-billing-label") do
      span(class: "font-medium text-gray-900") { @label }
      # span(class: "text-gray-500") { "(Save 10%)" }
    end
  end
end
