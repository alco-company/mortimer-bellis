class ToggleButton < ApplicationComponent
  #
  attr_accessor :resource, :label, :value, :url, :action, :attributes, :input_name

  def initialize(resource:, label: "toggle", value: false, url: nil, action: "click->boolean#toggle", attributes: {}, input_name: nil)
    @resource = resource
    @label = label
    @value = value
    @url = url
    @action = action
    @attributes = attributes
    @data_attr = attributes[:data] || {}
    @input_name = input_name || attributes[:name] || "#{resource.class.name.underscore}[#{resource.id}]"
  end

  def view_template
    div(class: attributes.dig(:class), data: { controller: "boolean" }) do
      input(name: input_name, data: @data_attr.merge({ boolean_target: "input" }), type: :hidden, value: setValue)
      button(
        type: "button",
        data: { action: (attributes.dig(:disabled) ? "" : action), boolean_target: "button" },
        class:
          "group relative inline-flex h-6 w-10 flex-shrink-0 cursor-pointer items-center justify-center rounded-full focus:outline-hidden focus:ring-1 focus:ring-sky-200 focus:ring-offset-1",
        role: "switch",
        aria_checked: "false"
      ) do
        span(class: "sr-only") { "Use setting" }
        span(
          aria_hidden: "true",
          class: "pointer-events-none absolute h-full w-full rounded-md bg-white"
        )
        comment { %(Enabled: "bg-sky-600", Not Enabled: "bg-gray-200") }
        span(
          aria_hidden: "true",
          data: { boolean_target: "indicator" },
          class:
            "#{setIndicator} pointer-events-none absolute mx-auto h-4 w-9 rounded-full transition-colors duration-200 ease-in-out"
        )
        comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
        span(
          aria_hidden: "true",
          data: { boolean_target: "handle" },
          class:
            "#{setHandle} pointer-events-none absolute left-0 inline-block h-5 w-5 transform rounded-full border border-gray-200 bg-white shadow-sm ring-0 transition-transform duration-200 ease-in-out"
        )
      end
    end
  end

  def setValue
    (value == true || value.to_s == "1") ? "1" : "0"
  end
  def setIndicator
    (value == true || value.to_s == "1") ? "bg-sky-600" : "bg-gray-200"
  end
  def setHandle
    (value == true || value.to_s == "1") ? "translate-x-5" : "translate-x-0"
  end
end


# old implementation - used on calendar aot

# def view_template
#   comment { %(Enabled: "bg-sky-200", Not Enabled: "bg-gray-200") }
#   button(
#     type: "button",
#     data: { toggle_button_target: "toggle", action: action },
#     class:
#       "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent #{ @toggled_on ? "bg-sky-200" : "bg-gray-200" } transition-colors duration-200 ease-in-out focus:outline-hidden focus:ring-1 focus:ring-sky-200 focus:ring-offset-1",
#     role: "switch",
#     aria_checked: @toggled_on ? "true" : "false",
#     aria_labelledby: "annual-billing-label"
#   ) do
#     comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
#     span(
#       data: { toggle_button_target: "toggleSpan" },
#       aria_hidden: "true",
#       class:
#         "pointer-events-none inline-block h-5 w-5 translate-x-0 transform rounded-full bg-white shadow-sm ring-0 transition duration-200 ease-in-out"
#     )
#   end

#   span(class: "ml-3 text-sm", id: "annual-billing-label") do
#     span(class: "font-medium text-gray-900") { @label }
#     # span(class: "text-gray-500") { "(Save 10%)" }
#   end
# end
