#
# the SelectComponent builds a select input field
# using <div role="listbox" popover><ul><li></li></ul><input class="hidden" /></div> elements
#
class SelectComponent < ApplicationComponent
  def initialize(resource:, field:, collection:, show_label: true, prompt: "", field_class: "mort-field", label_class: "text-red-500", value_class: "mr-5", editable: true)
    @resource = resource
    @field = field
    @collection = collection
    @show_label = show_label
    @prompt = prompt
    @field_class = field_class
    @label_class = label_class
    @value_class = value_class
    @editable = editable
  end

  def view_template
    if @show_label
      div(class: @field_class) do
        label(for: resource_field, class: @label_class) do
          span(class: "font-bold") do
            plain I18n.t("activerecord.attributes.#{ resource_field("%s.%s") }")
          end
        end
        @editable ?
          editable_view :
          div(class: @value_class) do
            plain @resource.send @field
          end
      end
    else
      @editable ?
        editable_view :
        div(class: @value_class) do
          plain @resource.send @field
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
        class: "mort-form-select"
      ) do
        @collection.each do |item|
          option(value: item.id, selected: item_selected?(item)) { item.value }
        end
      end
    end
  end

  def item_selected?(item)
    @resource.send(@field) == item.id
  end
end
