module FieldSpecializations
  extend ActiveSupport::Concern

  included do
  end

  #
  # Option Mapper
  #
  class OptionMapper < Superform::Rails::OptionMapper
    def each(&options)
      @collection.each do |item|
        case item
        in ActiveRecord::Relation => relation
          active_record_relation_options_enumerable(relation).each(&options)
        # in [TimeMaterial::State, *] => colr
        #   enumerable_list(colr).each(&options)
        in [Colorable::Color, *] => colr
          enumerable_list(colr).each(&options)
        in [Localeable::Locale, *] => locl
          enumerable_list(locl).each(&options)
        in [[ String, /^\([+-]\d{1,2}\:\d\d\)$/ ], *] => arr
          timezone_list(arr).each(&options)
        in [[ String, String ], *] => arr
          id_value_list(arr).each(&options)
        in [[ Integer, String ], *] => arr
          id_value_list(arr).each(&options)
        in [[ Symbol, String ], *] => arr
          id_value_list(arr).each(&options)
        in id, value
          options.call id, value
        in value
          options.call value, value.to_s
        end
      end
    end

    def enumerable_list(colr)
      Enumerator.new do |collection|
        colr.each do |color|
          collection << [ color.id, color.value ]
        end
      end
    end

    def timezone_list(tz)
      Enumerator.new do |collection|
        tz.each do |k, v|
          collection << [ k, "%s - %s" % [ v, k ] ]
        end
      end
    end

    def id_value_list(arr)
      Enumerator.new do |collection|
        arr.each do |k, v|
          collection << [ k, v ]
        end
      end
    end

    def value_value_list(arr)
      Enumerator.new do |collection|
        arr.each do |k|
          collection << [ k, v ]
        end
      end
    end

    def active_record_relation_options_enumerable(relation)
      Enumerator.new do |collection|
        relation.each do |object|
          attributes = object.attributes
          id = attributes.delete(relation.primary_key)
          value = attributes.values.join(" ")
          collection << [ id, value ]
        end
      end
    end
  end

  #
  # *Field Components
  #
  class InputField < Superform::Rails::Components::InputComponent
    def field_attributes
      field.value = @attributes[:value] if @attributes[:value]
      @attributes.keys.include?(:class) ? super : super.merge(class: "mort-form-text")
    end
  end

  class MoneyField < Superform::Rails::Components::InputComponent
    def field_attributes
      field.value = @attributes[:value] ? @attributes[:value] : I18n.t("number.currency.format.unit") + " " + field.value
      @attributes.keys.include?(:class) ? super : super.merge(class: "mort-form-text")
    end
  end

  class NumberField < Superform::Rails::Components::InputComponent
    def field_attributes
      field.value = @attributes[:value] if @attributes[:value]
      @attributes.keys.include?(:class) ? super.merge(type: "number") : super.merge(class: "mort-form-text", type: "number")
    end
  end

  class LookupField < Superform::Rails::Components::SelectField
    # include Phlex::Rails::Helpers::Request
    #
    def view_template(&)
      field.value = @attributes[:value] if @attributes[:value]

      div(class: "relative", data: { controller: "lookup" }) do
        input(type: "hidden", id: dom.id, name: dom.name, value: field.value, data: { lookup_target: "selectId" })
        data = attributes[:data] || { url: attributes[:lookup_path], div_id: field.dom.id, lookup_target: "input", action: "keydown->lookup#keyDown" }
        css = attributes[:class] || "mort-form-text"
        input(
          data: data,
          type: "text",
          list:  "%s_lookup_options" % field.dom.id,
          value: attributes[:display_value],
          id: dom.id.gsub(/_id$/, "_name"),
          name: dom.name.gsub(/_id\]/, "_name]"),
          class: css, # "w-full rounded-md border-0 bg-white py-1.5 pl-3 pr-12 text-gray-900 shadow-xs ring-1 ring-inset ring-gray-300 focus:ring-1 focus:ring-inset focus:ring-sky-200 sm:text-sm sm:leading-6",
          role: attributes[:role] || "combobox",
          autocomplete: "off",
          aria_controls: "options",
          aria_expanded: "false"
        )
        hide = @collection.any? ? "" : "hidden"
        button(type: "button", data: { lookup_target: "optionsIcon", action: "click->lookup#toggleOptions" }, class: "#{hide} absolute w-10 inset-y-0 right-0 flex items-center rounded-r-md px-2 focus:ring-1 focus:ring-inset focus:ring-sky-200 focus:outline-hidden") do
          render Icons::ChevronUpDown.new css: "h-5 w-5 text-gray-400"
        end
        hide = (!hide.blank? && field.value.nil?) ? "" : "hidden"
        button(type: "button", data: { lookup_target: "searchIcon", action: "click->lookup#search" }, class: "#{hide} absolute w-10 inset-y-0 right-0 flex items-center rounded-r-md px-2 focus:ring-1 focus:ring-inset focus:ring-sky-200 focus:outline-hidden") do
          render Icons::Search.new cls: "text-gray-400 right-2 top-0 h-full w-5 absolute pointer-events-none"
        end
        collection = @collection[0] rescue []
        render SelectLookup.new(collection: collection, div_id: field.dom.id, field_value: field.value)
      end
    end

    protected
      def map_options(collection)
        OptionMapper.new(collection)
      end
  end

  class SelectField < Superform::Rails::Components::SelectField
    def field_attributes
      @attributes.keys.include?(:class) ? super : super.merge(class: "mort-form-select")
    end

    #
    def view_template(&)
      div(class: "grid grid-cols-1") do
        select(**attributes) do
          options(*@collection)
        end
        svg(
          class:
            "pointer-events-none col-start-1 row-start-1 mr-2 size-5 self-center justify-self-end text-gray-500 sm:size-4",
          viewbox: "0 0 16 16",
          fill: "currentColor",
          aria_hidden: "true",
          data_slot: "icon"
        ) do |s|
          s.path(
            fill_rule: "evenodd",
            d:
              "M4.22 6.22a.75.75 0 0 1 1.06 0L8 8.94l2.72-2.72a.75.75 0 1 1 1.06 1.06l-3.25 3.25a.75.75 0 0 1-1.06 0L4.22 7.28a.75.75 0 0 1 0-1.06Z",
            clip_rule: "evenodd"
          )
        end
      end
    end
    protected
      def map_options(collection)
        OptionMapper.new(collection)
      end
  end

  class EnumSelectField < SelectField
    def options(*collection)
      collection.flatten!
      map_options(collection).each do |key, value|
        option(selected: field.value.include?(key), value: key) { value }
      end
    end
  end

  class MultipleSelectField < Superform::Rails::Components::SelectField
    def options(*collection)
      map_options(collection).each do |key, value|
        option(selected: field.value.include?(key), value: key) { value }
      end
    end
  end

  class WeekField < InputField
    def field_attributes
      super.merge(type: "week")
    end
    def view_template(&)
      input(**attributes, value: field.value&.strftime("%Y-W%V"))
    end
  end

  class FileField < InputField
    include Phlex::Rails::Helpers::LinkTo

    def field_attributes
      @attributes.keys.include?(:multiple) ? super.merge(type: "file", accept: "image/*", multiple: true) : super.merge(type: "file", accept: "image/*")
    end

    def view_template(&)
      div(class: "mort-field") do
        input(**attributes)
        if field.value.attached?
          div(class: "w-auto max-w-32 relative border border-slate-100 rounded-md shadow-sm px-3 mt-3") do
            img(src: url_for(field.value), class: "mort-img m-2")
            div(class: "absolute top-0 right-0 w-8 h-8 rounded-lg bg-white/75") do
              link_to(
                helpers.new_modal_url(modal_form: "delete", id: field.parent.object.id, attachment: field.value.name, api_key: @_parent.api_key, resource_class: field.parent.object.class.to_s.underscore, modal_next_step: "accept"),
                data: { turbo_stream: true },
                # link_to((@links[1] || resource),
                class: "absolute top-1 right-1",
                role: "menuitem",
                tabindex: "-1") do
                  div(class: "text-red-500") do
                    svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor", stroke: "currentColor", class: "") do |s|
                      s.path(d: "m376-300 104-104 104 104 56-56-104-104 104-104-56-56-104 104-104-104-56 56 104 104-104 104 56 56Zm-96 180q-33 0-56.5-23.5T200-200v-520h-40v-80h200v-40h240v40h200v80h-40v520q0 33-23.5 56.5T680-120H280Zm400-600H280v520h400v-520Zm-400 0v520-520Z")
                    end
                  end
              end
            end
          end
        end
      end
    end
  end

  class BooleanField < Superform::Rails::Components::CheckboxComponent
    def field_attributes
      @attributes.keys.include?(:class) ? super.merge(type: "boolean") : super.merge(class: "mort-form-text", type: "boolean")
    end
    def view_template(&)
      field.value = attributes[:value] if attributes[:value]
      data_attr = attributes[:data] || {}
      div(class: attributes[:class], data: { controller: "boolean" }) do
        input(name: dom.name, data: data_attr.merge({ boolean_target: "input" }), type: :hidden, value: setValue)
        button(
          type: "button",
          data: { action: (attributes[:disabled] ? "" : "click->boolean#toggle"), boolean_target: "button" },
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
      (field.value == true || field.value.to_s == "1") ? "1" : "0"
    end
    def setIndicator
      (field.value == true || field.value.to_s == "1") ? "bg-sky-600" : "bg-gray-200"
    end
    def setHandle
      (field.value == true || field.value.to_s == "1") ? "translate-x-5" : "translate-x-0"
    end
  end

  #
  # Work In Progress - 2024-07-16
  #
  # class PillField < BooleanField
  #   include Phlex::Rails::Helpers::CollectionRadioButtons
  #   include Phlex::Rails::Helpers::RadioButton

  #   def template(&)
  #     fieldset(class: "inline-block whitespace-nowrap p-px border-2 rounded-full focus-within:outline focus-within:outline-blue-400") do
  #       # plain collection_radio_buttons(**attributes) do |builder|
  #       plain collection_radio_buttons(:user, :punching_absence, [ true, "Option 1", false, "option 2" ]) do |builder|
  #         span(class: "relative inline-block") do
  #           plain builder.radio_button class: "sr-only peer"
  #           plain builder.label(class: "border-2 border-transparent rounded-full block py-1 px-2 peer-checked:bg-blue-500 peer-checked:text-white hover:bg-blue-200 hover:border-sky-200")
  #         end
  #       end
  #     end
  #   end
  # end

  class HiddenField < InputField
    def field_attributes
      super.merge(type: "hidden")
    end
    def view_template(&)
      input(**attributes, value: field.value)
    end
  end

  class TimeField < InputField
    def field_attributes
      @attributes.keys.include?(:class) ? super.merge(type: "time") : super.merge(class: "mort-form-text", type: "time")
    end
    def view_template(&)
      input(**attributes, value: field.value&.strftime("%H:%M"))
    end
  end

  class DateField < InputField
    def field_attributes
      @attributes.keys.include?(:class) ? super.merge(type: "date") : super.merge(class: "mort-form-text", type: "date")
    end
    def view_template(&)
      fld = field.value.class == String ? field.value : field.value&.strftime("%Y-%m-%d") rescue nil
      input(**attributes, value: fld)
    end
  end
  class DateTimeField < InputField
    def field_attributes
      @attributes.keys.include?(:class) ? super.merge(type: "datetime-local") : super.merge(class: "mort-form-text", type: "datetime-local")
    end
    def view_template(&)
      input(**attributes, value: field.value&.strftime("%Y-%m-%dT%H:%M"))
    end
  end

  class Field < Superform::Rails::Form::Field
    def lookup(*collection, **attributes, &)
      LookupField.new(self, attributes: attributes, collection: collection, &)
    end
    def select(*collection, **attributes, &)
      SelectField.new(self, attributes: attributes, collection: collection, &)
    end
    def multiple_select(*collection, **attributes, &)
      MultipleSelectField.new(self, attributes: attributes, collection: collection, &)
    end
    def enum_select(*collection, **attributes, &)
      EnumSelectField.new(self, attributes: attributes, collection: collection, &)
    end
    def file(**attributes)
      FileField.new(self, attributes: attributes)
    end
    def boolean(**attributes)
      BooleanField.new(self, attributes: attributes)
    end
    def hidden(**attributes)
      HiddenField.new(self, attributes: attributes)
    end
    #   PillField.new(self, attributes: attributes)
    # end
    def week(**attributes)
      WeekField.new(self, attributes: attributes)
    end
    def time(**attributes)
      TimeField.new(self, attributes: attributes)
    end
    def date(**attributes)
      DateField.new(self, attributes: attributes)
    end
    def datetime(**attributes)
      DateTimeField.new(self, attributes: attributes)
    end
    def money(**attributes)
      MoneyField.new(self, attributes: attributes)
    end
    def number(**attributes)
      NumberField.new(self, attributes: attributes)
    end
    def input(**attributes)
      InputField.new(self, attributes: attributes)
    end
    def password(**attributes)
      attributes.merge!(type: "password")
      InputField.new(self, attributes: attributes)
    end
  end
end
