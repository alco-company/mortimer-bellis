#
# the SelectComponent builds a select input field
# using <div role="listbox" popover><ul><li></li></ul><input class="hidden" /></div> elements
#
class SelectComponent < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag

  attr_accessor :resource, :field, :collection, :show_label, :prompt, :field_class, :label_class, :value_class, :editable, :hint, :attributes, :url, :target

  def initialize(resource:, field:, collection:, show_label: true, prompt: "", field_class: "mort-field", label_class: "text-red-500", value_class: "mr-5", editable: true, hint: nil, attributes: {}, url: nil, target: nil)
    @resource = resource
    @field = field
    @collection = collection
    @show_label = show_label
    @prompt = prompt
    @field_class = field_class
    @label_class = label_class
    @value_class = value_class
    @editable = editable
    @hint = hint
    @url = url
    @target = target
    @attributes = attributes
    @method = attributes[:method] || resource.persisted? ? :put : :post
    @key = attributes[:key] || resource.name.underscore
    @data_attr = attributes[:data] || {}
  end

  def view_template
    turbo_frame_tag @target, class: "grow" do
      div(class: attributes.dig(:class), data: { url: url, controller: "select", method: @method, select_key_value: @key }) do
        if @show_label
          div(class: @field_class) do
            label(for: resource_field, class: @label_class) do
              span(class: "font-bold") do
                plain t("activerecord.attributes.#{ resource_field("%s.%s") }")
              end
            end
            @editable ? editable_view : show_view
          end
        else
          @editable ? editable_view : show_view
          span(class: "ml-4 shrink-0", data: { select_target: "editbutton", action: "click->select#edit" }) do
            render Icons::Edit.new css: "w-6 h-6 text-sky-500 hover:text-gray-700 cursor-pointer"
          end
          span(class: "hidden ml-4 shrink-0", data: { select_target: "savebutton", action: "click->select#change" }) do
            render Icons::Checkmark.new css: "w-6 h-6 text-green-500 hover:text-gray-700 cursor-pointer"
          end
        end
      end
    end
  end

  def resource_field(joined = "%s_%s")
    joined % [ @resource.class.to_s.underscore, @field.to_s.underscore ]
  end

  def editable_view
    div(class: @value_class) do
      select(
        id: resource_field,
        name: resource_field("%s[%s]"),
        prompt: @prompt,
        data: @data_attr.merge({ select_target: "input" }),
        class: "mort-form-select"
      ) do
        @collection.each do |item|
          option(value: item_id(item), selected: item_selected?(item)) { item_value(item) }
        end
      end
      span(data: { select_target: "output" }, class: "grow") { @resource.send(@field) }
      span(class: "text-sm/6 text-gray-500") { @hint } if @hint
    end
  end

  def show_view
    div(class: @value_class) do
      select(
        id: resource_field,
        name: resource_field("%s[%s]"),
        prompt: @prompt,
        data: @data_attr.merge({ select_target: "input" }),
        class: "hidden mort-form-select"
      ) do
        @collection.each do |item|
          option(value: item_id(item), selected: item_selected?(item)) { item_value(item) }
        end
      end
      span(data: { select_target: "output" }, class: "grow") { @resource.send(@field) }
      span(class: "text-sm/6 text-gray-500") { @hint } if @hint
    end
  end

  def item_selected?(item)
    @resource.send(@field) == item_id(item)
  end

  def item_id(item)
    return item.id if item.respond_to?(:id)
    case item.class.to_s
    when "Array"
      item.first if item.any?
    end
  end

  def item_value(item)
    return item.value if item.respond_to?(:value)
    case item.class.to_s
    when "Array"
      item.last if item.any?
    else
      item.to_s
    end
  end
end
