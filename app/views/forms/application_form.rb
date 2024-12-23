class ApplicationForm < Superform::Rails::Form
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :resource, :cancel_url, :title, :edit_url,  :editable, :api_key, :model, :fields

  def initialize(resource:, editable: nil, **options)
    options[:data] = { form_target: "form" }
    options[:class] = "mort-form"
    @fields = options[:fields] || []
    super(resource, **options)
    @resource = @model = resource
    @editable = editable
    @api_key = options[:api_key] || ""
  end

  def view_template(&)
    form_fields fields: fields
  end

  class Phlex::SGML
    def format_object(object)
      case object.class.to_s
      when "ActiveSupport::TimeWithZone"; object.strftime("%d-%m-%y")
      when "Array"; object.map { |o| format_object(o) }.join(", ")
      when "Date"; object.strftime("%Y-%m-%d")
      when "DateTime"; object.strftime("%Y-%m-%d %H:%M:%S")
      when "Decimal", "BigDecimal", "Float", "Integer"; object.to_s
      when "Phlex::SGML::Decimal"; object.to_s
      when "FalseClass"; I18n.t(:no)
      when "TrueClass"; I18n.t(:yes)
      when "NilClass"; ""
      else; object
      end
    rescue => err
      UserMailer.error_report(err.to_s, "Phlex::SGML format_object error with object #{ object.class }").deliver_later
    end
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
  class LookupField < Superform::Rails::Components::SelectField
    # include Phlex::Rails::Helpers::Request
    #
    def view_template(&)
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
          class: css, # "w-full rounded-md border-0 bg-white py-1.5 pl-3 pr-12 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:ring-1 focus:ring-inset focus:ring-sky-200 sm:text-sm sm:leading-6",
          role: attributes[:role] || "combobox",
          autocomplete: "off",
          aria_controls: "options",
          aria_expanded: "false"
        )
        hide = @collection.any? ? "" : "hidden"
        button(type: "button", data: { lookup_target: "optionsIcon", action: "click->lookup#toggleOptions" }, class: "#{hide} absolute w-10 inset-y-0 right-0 flex items-center rounded-r-md px-2 focus:ring-1 focus:ring-inset focus:ring-sky-200 focus:outline-none") do
          render Icons::ChevronUpDown.new cls: "h-5 w-5 text-gray-400"
        end
        hide = (!hide.blank? && field.value.nil?) ? "" : "hidden"
        button(type: "button", data: { lookup_target: "searchIcon", action: "click->lookup#search" }, class: "#{hide} absolute w-10 inset-y-0 right-0 flex items-center rounded-r-md px-2 focus:ring-1 focus:ring-inset focus:ring-sky-200 focus:outline-none") do
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
    protected
      def map_options(collection)
        OptionMapper.new(collection)
      end
  end

  class EnumSelectField < Superform::Rails::Components::SelectField
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

  class WeekField < Superform::Rails::Components::InputComponent
    def field_attributes
      super.merge(type: "week")
    end
  end

  class FileField < Superform::Rails::Components::InputComponent
    include Phlex::Rails::Helpers::LinkTo

    def field_attributes
      @attributes.keys.include?(:multiple) ? super.merge(type: "file", accept: "image/*", multiple: true) : super.merge(type: "file", accept: "image/*")
    end

    def view_template(&)
      div(class: "mort-field") do
        input(**attributes)
        if field.value.attached?
          div(class: "w-auto max-w-32 relative border rounded-md shadow px-3 mt-3") do
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
      super.merge(type: "boolean")
    end
    def view_template(&)
      data_attr = attributes[:data] || {}
      div(class: attributes[:class], data: { controller: "boolean" }) do
        input(name: dom.name, data: data_attr.merge({ boolean_target: "input" }), type: :hidden, value: setValue)
        button(
          type: "button",
          data: { action: (attributes[:disabled] ? "" : "click->boolean#toggle"), boolean_target: "button" },
          class:
            "group relative inline-flex h-6 w-10 flex-shrink-0 cursor-pointer items-center justify-center rounded-full focus:outline-none focus:ring-1 focus:ring-sky-200 focus:ring-offset-1",
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
              "#{setHandle} pointer-events-none absolute left-0 inline-block h-5 w-5 transform rounded-full border border-gray-200 bg-white shadow ring-0 transition-transform duration-200 ease-in-out"
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

  class HiddenField < Superform::Rails::Components::InputComponent
    def field_attributes
      super.merge(type: "hidden")
    end
    def view_template(&)
      input(**attributes, value: field.value)
    end
  end

  class TimeField < Superform::Rails::Components::InputComponent
    def field_attributes
      super.merge(type: "time")
    end
    def view_template(&)
      input(**attributes, value: field.value&.strftime("%H:%M"))
    end
  end

  class DateField < Superform::Rails::Components::InputComponent
    def field_attributes
      super.merge(type: "date")
    end
    def view_template(&)
      fld = field.value.class == String ? field.value : field.value&.strftime("%Y-%m-%d") rescue nil
      input(**attributes, value: fld)
    end
  end
  class DateTimeField < Superform::Rails::Components::InputComponent
    def field_attributes
      super.merge(type: "datetime-local")
    end
    def view_template(&)
      input(**attributes, value: field.value&.strftime("%Y-%m-%dT%H:%M"))
    end
  end

  class Field < Field
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
  end

  def qr_code(component, value)
    div(class: "mort-field") do
      helpers.svg_qr_code_link(value)
    end
  end

  def hidden(component)
    div do
      render component
    end
  end

  def view_only(component, outer_class = "mort-field")
    div do
      render(component.field.label) do
        plain I18n.t("activerecord.attributes.#{component.field.parent.key}.#{component.field.key}")
        # span(class: "font-bold") do
        # end
      end
      div(class: outer_class) do
        display_field(component.field)
      end
    end
  end

  def row(component, outer_class = "mort-field")
    div(class: outer_class) do
      render(component.field.label) do
        plain I18n.t("activerecord.attributes.#{component.field.parent.key}.#{component.field.key}")
        # span(class: "text-sm font-light") do
        # end
      end unless component.class == ApplicationForm::HiddenField
      @editable ?
        render(component) :
        div(class: "mr-5") do
          model.field_formats(component.field.key) == :file ?
          display_image(component.field) :
          display_field(component.field)
        end
    end
  end

  def naked_row(component)
    div() do
      render(component.field.label) do
        plain I18n.t("activerecord.attributes.#{component.field.parent.key}.#{component.field.key}")
        # span(class: "text-sm font-light") do
        # end
      end unless component.class == ApplicationForm::HiddenField
      @editable ?
        render(component) :
        div(class: "mr-5") do
          model.field_formats(component.field.key) == :file ?
          display_image(component.field) :
          display_field(component.field)
        end
    end
  end

  def display_field(field)
    case field.key
    when /tenant_id$/; plain(model&.tenant&.name)
    when /team_id$/; div(class: "flex") { link_to(model&.team&.name, team_url(model&.team), class: "flex place-items-center truncate mort-btn-secondary") } # plain(model&.team.name)
    when /user_id$/;  div(class: "flex") { link_to(model&.user&.name, user_url(model&.user), class: "flex place-items-center truncate mort-btn-secondary") } # plain(model&.user&.name)
    when /customer_id$/; div(class: "flex") { link_to(model&.customer&.name, customer_url(model&.customer), class: "flex place-items-center truncate mort-btn-secondary") }
    when /project_id$/;  div(class: "flex") { link_to(model&.project&.name, project_url(model&.project), class: "flex place-items-center truncate mort-btn-secondary") }
    when /product_id$/; div(class: "flex") { link_to(model&.product&.name, product_url(model&.product), class: "flex place-items-center truncate mort-btn-secondary") }
    when /punch_clock_id$/; div(class: "flex") { link_to(model&.punch_clock&.name, punch_clock_url(model&.punch_clock), class: "flex place-items-center truncate mort-btn-secondary") } # plain(model&.punch_clock&.name) rescue I18n.t("punches.form.punched_on_app")
    else; plain(fformat(model, field.key))
    end
  rescue
    " fejl #{field.key} - #{model.class} "
  end

  def display_image(field)
    if model.send(field.key).attached?
      div(class: "mort-field") do
        img(src: url_for(model.send(field.key)), class: "mort-img")
      end
    end
  end

  def fformat(model, key)
    case model.field_formats(key)
    when :date; model.send(key).strftime("%d-%m-%Y") rescue nil
    when :datetime; model.send(key).strftime("%d-%m-%Y %H:%M") rescue nil
    when :time; model.send(key).strftime("%H:%M") rescue nil
    when :enum; I18n.t("#{model.class.to_s.underscore}.#{model.send(key)}")
    when :boolean; (model.send(key) ? I18n.t(:yes) : I18n.t(:no))
    when :association; eval("model.#{key}") rescue "n/a"
    else; model.send key
    end
  end

  def around_template(&)
    super do
      div(class: "") do
        error_messages
        yield
      end
    end
  end

  def submit_string
    model.new_record? ? I18n.t(:create) : I18n.t(:update)
  end

  def error_messages
    if model.errors.any?
      div(id: "error_explanation", class: "mt-4 p-4 sm: p-1") do
        h2(class: "mort-err-resume") { I18n.t(:form_errors_prohibited, errors: model.errors.count) }
        ul do
          model.errors.each do |error|
            li { error.full_message }
          end
        end
      end
    end
  end

  def form_fields(fields: [])
    @fields = fields
    model.class.attribute_types.each do |key, type|
      if fields_include?(key)
        case type.class.to_s
        when "ActiveModel::Type::String"; row field(key.to_sym).input(class: "mort-form-text")
        when "ActiveRecord::Type::Text"; row field(key.to_sym).textarea(class: "mort-form-text")
        else
          plain raw_unsafe "<!-- #{key} - #{type.class} -->"
        end
      end
    end
  end

  def fields_include?(key)
    return false unless fields.any?
    fields.include?(key.to_sym)
  end
end
