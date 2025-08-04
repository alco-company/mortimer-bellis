class TextBox < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  #
  attr_accessor :resource, :label, :value, :hint, :url, :action, :attributes, :input_name

  def initialize(resource:, label: "text", state: "show", value: false, hint: nil, target: nil, url: nil, action: nil, attributes: {}, input_name: nil)
    @resource = resource
    @label = label
    @value = value
    @hint = hint
    @state = state
    @target = target || "#{resource.class.name.underscore}_#{resource.id}"
    @url = url
    @method = attributes[:method] || resource.persisted? ? :put : :post
    @attributes = attributes
    @data_attr = attributes[:data] || {}
    @data_attr = @data_attr.merge({ action: action }) if action

    @key = attributes[:key] || resource.name.underscore
    @input_name = input_name || attributes[:name] || "#{resource.class.name.underscore}[#{resource.id}]"
  end

  def view_template
    cls = @state == "show" ? "hidden" : ""
    turbo_frame_tag @target, class: "grow" do
      div(class: attributes.dig(:class), data: { url: url, controller: "text", method: @method, text_key_value: @key }) do
        span(class: "grow") do
          div(class: "flex flex-col gap-1") do
            input(
              name: input_name,
              type: "text",
              data: @data_attr.merge({ text_target: "input" }),
              class: "#{cls} mort-form-text",
              role: "text",
              value: value
            )
            span(data: { text_target: "output" }, class: "grow") { value }
            span(class: "text-sm/6 text-gray-500") { hint }
          end
        end
        span(class: "ml-4 shrink-0", data: { text_target: "editbutton", action: "click->text#edit" }) do
          render Icons::Edit.new css: "w-6 h-6 text-sky-500 hover:text-gray-700 cursor-pointer"
        end
        span(class: "hidden ml-4 shrink-0", data: { text_target: "savebutton", action: "click->text#update" }) do
          render Icons::Checkmark.new css: "w-6 h-6 text-green-500 hover:text-gray-700 cursor-pointer"
        end
      end
    end
  end
end
