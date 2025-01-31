class FieldComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::OptionsForSelect

  attr_accessor :model, :model_name, :field, :filter, :value, :selected, :selected_text, :editable

  def initialize(model:, field:, filter: Filter.new, value: nil, selected: nil, editable: false, &block)
    @model = model
    @field = field
    @filter = filter
    @editable = editable
    @value = value
    @selected = selected
    set_variables
  end

  def view_template(&block)
    li(id: "li_#{model_name}_#{field}", class: "rounded-md") do
      if editable
        type =model.columns_hash[field.to_s].type
        case type
        when :datetime, :date; date_field_input(type)
        when :boolean; boolean_field_input
        when :integer; integer_field_input
        else string_field_input
        end
      else
        string_field
      end
    end
  end

  def string_field
    link_to new_filter_fields_url(
          model: model_name,
          field: field,
          value: value,
          selected: selected
        ),
        class:
          "flex rounded-md py-2 pl-10 pr-2 text-sm font-semibold leading-6 text-gray-700 hover:bg-gray-50",
        data: {
          turbo_prefetch: "false",
          turbo_stream: "true"
        } do
      field_value = (value.blank? ? "" : "#{selected_text} '#{value}'")
      input(
        type: "hidden",
        id: "id_#{model_name}-#{field}",
        name: "filter[#{model_name}][#{field}]",
        value: "#{selected}|#{value}"
      )
      span(class: "text-sm font-semibold leading-6") do
        plain I18n.t("activerecord.attributes.#{model_name}.#{field}")
      end
      span(class: "ml-2 text-sm font-thin") { field_value }
    end
  end

  def string_field_input
    div(class: "mort-field grid grid-cols-5 gap-2") do
      label(class: "col-span-5", for: "id_#{model_name}-#{field}") { I18n.t("activerecord.attributes.#{model_name}.#{field}") }
      select(
        name: %(#{"#{model_name}_#{field}"}_selector),
        data_filter_target: "selector",
        class: "mort-form-select col-span-2"
      ) do
        options_for_select Filter::SELECTORS, selected
      end
      input(
        name: "#{model_name}-#{field}",
        id: "id_#{model_name}-#{field}",
        placeholder: I18n.t("value"),
        class: "mort-form-text col-span-2",
        value: value,
        data_filter_target: "input"
      )
      button(
        data_action: " click->filter#submitField",
        class:
          "col-span-1 relative rounded-md justify-self-end bg-white text-gray-400 hover:text-gray-500 focus:ring-1 focus:ring-sky-200"
      ) do
        render Icons::Checkmark.new cls: "h-6 w-6 text-green-500"
      end
    end
  end

  def date_field_input(type)
    div(class: "mort-field grid grid-cols-5 gap-2") do
      label(class: "col-span-5", for: "id_#{model_name}-#{field}") { I18n.t("activerecord.attributes.#{model_name}.#{field}") }
      select(
        name: %(#{"#{model_name}_#{field}"}_selector),
        data_filter_target: "selector",
        class: "mort-form-select col-span-2"
      ) do
        options_for_select Filter::SELECTORS, selected
      end
      input(
        type: type,
        name: "#{model_name}-#{field}",
        id: "id_#{model_name}-#{field}",
        placeholder: I18n.t("value"),
        class: "mort-form-text col-span-2",
        value: value,
        data_filter_target: "input"
      )
      button(
        data_action: " click->filter#submitField",
        class:
          "col-span-1 relative rounded-md justify-self-end bg-white text-gray-400 hover:text-gray-500 focus:ring-1 focus:ring-sky-200"
      ) do
        render Icons::Checkmark.new cls: "h-6 w-6 text-green-500"
      end
    end
  end

  def boolean_field_input
    div(class: "mort-field grid grid-cols-5 gap-2") do
      label(class: "col-span-5", for: "id_#{model_name}-#{field}") { I18n.t("activerecord.attributes.#{model_name}.#{field}") }
      input(type: "hidden",
        name: %(#{"#{model_name}_#{field}"}_selector),
        id: "id_#{model_name}-#{field}_selector",
        data_filter_target: "selector",
        value: "eq")
      div(class: "my-auto mort-form-bool", data_controller: "boolean") do
        input(
          name: "#{model_name}-#{field}",
          id: "id_#{model_name}-#{field}",
          data_time_material_target: "invoice",
          data_boolean_target: "input",
          data_filter_target: "input",
          type: "hidden",
          value: "0"
        )
        button(
          type: "button",
          data_action: " click->boolean#toggle",
          data_boolean_target: "button",
          class:
            "group relative inline-flex h-6 w-10 flex-shrink-0 cursor-pointer items-center justify-center rounded-full focus:outline-none focus:ring-1 focus:ring-sky-200 focus:ring-offset-1",
          role: "switch",
          aria_checked: "false"
        ) do
          span(class: "sr-only") { "Use setting" }
          span(
            aria_hidden: "true",
            class:
              "pointer-events-none absolute h-full w-full rounded-md bg-white"
          )
          comment do
            "Enabled: &quot;bg-sky-600&quot;, Not Enabled: &quot;bg-gray-200&quot;"
          end
          span(
            aria_hidden: "true",
            data_boolean_target: "indicator",
            class:
              "bg-gray-200 pointer-events-none absolute mx-auto h-4 w-9 rounded-full transition-colors duration-200 ease-in-out"
          )
          comment do
            "Enabled: &quot;translate-x-5&quot;, Not Enabled: &quot;translate-x-0&quot;"
          end
          span(
            aria_hidden: "true",
            data_boolean_target: "handle",
            class:
              "translate-x-0 pointer-events-none absolute left-0 inline-block h-5 w-5 transform rounded-full border border-gray-200 bg-white shadow ring-0 transition-transform duration-200 ease-in-out"
          )
        end
      end
      button(
        data_action: " click->filter#submitField",
        class:
          "col-span-1 relative rounded-md justify-self-end bg-white text-gray-400 hover:text-gray-500 focus:ring-1 focus:ring-sky-200"
      ) do
        render Icons::Checkmark.new cls: "h-6 w-6 text-green-500"
      end
    end
  end

  def integer_field_input
      label(class: "col-span-5", for: "id_#{model_name}-#{field}") { I18n.t("activerecord.attributes.#{model_name}.#{field}") }
    div do
      plain "integer_field"
    end
  end

  def set_variables
    filter.filter ||= {}
    @model_name = model.to_s.underscore
    s, v = filter.filter[model_name] && filter.filter[model_name][field] ?
      filter.filter[model_name][field].split("|") :
      [ "", "" ]
    @value ||= v
    @selected ||= s
    @selected_text = Filter::SELECTORS.filter { |s| s[1] == selected }.first[0] rescue ""
  end
end
