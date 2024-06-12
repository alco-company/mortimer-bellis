class ApplicationForm < Superform::Rails::Form
  include Phlex::Rails::Helpers::Pluralize

  attr_accessor :editable, :api_key

  def initialize(model, **options)
    super(model, **options)
    @editable = options[:editable]
    @api_key = options[:api_key] || ""
  end

  class Phlex::SGML
    def format_object(object)
      case object
      when ActiveSupport::TimeWithZone; object.strftime("%d-%m-%y")
      when Date; object.strftime("%Y-%m-%d")
      when DateTime; object.strftime("%Y-%m-%d %H:%M:%S")
      when Float, Integer; object.to_s
      when FalseClass; I18n.t(:no)
      when TrueClass; I18n.t(:yes)
      when NilClass; ""
      else
        # debugger
        object
      end
    end
  end

  class OptionMapper < Superform::Rails::OptionMapper
    def each(&options)
      @collection.each do |item|
        case item
        in ActiveRecord::Relation => relation
          active_record_relation_options_enumerable(relation).each(&options)
        in [Colorable::Color, *] => colr
          enumerable_list(colr).each(&options)
        in [Localeable::Locale, *] => locl
          enumerable_list(locl).each(&options)
        in [[ /GMT/, String ], *] => arr
          timezone_list(arr).each(&options)
        in [[ String, String ], *] => arr
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
          collection << [ v, "%s - %s" % [ v, k ] ]
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
      super.merge(type: "file", accept: "image/*")
    end
    def template(&)
      div(class: "mort-field") do
        input(**attributes)
        if field.value.attached?
          div(class: "w-auto max-w-32 relative border rounded-md shadow px-3 mt-3") do
            img(src: url_for(field.value), class: "mort-img m-2")
            div(class: "absolute top-0 right-0 w-8 h-8 rounded-lg bg-white/75") do
              link_to(
                helpers.modal_new_url(modal_form: "delete", id: field.parent.object.id, attachment: field.value.name, api_key: @_parent.api_key, resource_class: field.parent.object.class.to_s.underscore, modal_next_step: "accept"),
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
    def template(&)
      div(class: attributes[:class], data: { controller: "boolean"}) do
        input(name: dom.name, data: { boolean_target: "input" }, type: :hidden, value: field.value ? "1" : "0")
        button(
          type: "button",
          data: { action: "click->boolean#toggle", boolean_target: "button" },
          class:
            "group relative inline-flex h-5 w-10 flex-shrink-0 cursor-pointer items-center justify-center rounded-full focus:outline-none focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2",
          role: "switch",
          aria_checked: "false"
        ) do
          whitespace
          span(class: "sr-only") { "Use setting" }
          whitespace
          span(
            aria_hidden: "true",
            class: "pointer-events-none absolute h-full w-full rounded-md bg-white"
          )
          whitespace
          comment { %(Enabled: "bg-indigo-600", Not Enabled: "bg-gray-200") }
          whitespace
          span(
            aria_hidden: "true",
            data: { boolean_target: "indicator" },
            class:
              "#{setIndicator} pointer-events-none absolute mx-auto h-4 w-9 rounded-full transition-colors duration-200 ease-in-out"
          )
          whitespace
          comment { %(Enabled: "translate-x-5", Not Enabled: "translate-x-0") }
          whitespace
          span(
            aria_hidden: "true",
            data: { boolean_target: "handle" },
            class:
              "#{setHandle} pointer-events-none absolute left-0 inline-block h-5 w-5 transform rounded-full border border-gray-200 bg-white shadow ring-0 transition-transform duration-200 ease-in-out"
          )
        end
      end
    end
    def setIndicator
      field.value ? "bg-sky-600" : "bg-gray-200"
    end
    def setHandle
      field.value ? "translate-x-5" : "translate-x-0"
    end
  end

  class TimeField < Superform::Rails::Components::InputComponent
    def field_attributes
      super.merge(type: "time")
    end
    def template(&)
      input(**attributes, value: field.value&.strftime("%H:%M"))
    end
  end

  class DateField < Superform::Rails::Components::InputComponent
    def field_attributes
      super.merge(type: "date")
    end
    def template(&)
      input(**attributes, value: field.value&.strftime("%Y-%m-%d"))
    end
  end
  class DateTimeField < Superform::Rails::Components::InputComponent
    def field_attributes
      super.merge(type: "datetime-local")
    end
    def template(&)
      input(**attributes, value: field.value&.strftime("%Y-%m-%dT%H:%M"))
    end
  end

  class Field < Field
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

  def view_only(component)
    div do
      render(component.field.label) do
        span(class: "font-bold") do
          plain I18n.t("activerecord.attributes.#{component.field.parent.key}.#{component.field.key}")
        end
      end
      div(class: "mort-field") do
        display_field(component.field)
      end
    end
  end

  def row(component)
    div(class: "mort-field") do
      render(component.field.label) do
        span(class: "font-bold") do
          plain I18n.t("activerecord.attributes.#{component.field.parent.key}.#{component.field.key}")
        end
      end
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
    when /account_id$/; plain(model&.account.name)
    when /team_id$/; plain(model&.team.name)
    when /user_id$/; plain(model&.user.name)
    when /employee_id$/; plain(model&.employee.name)
    when /punch_clock_id$/; plain(model&.punch_clock.name) rescue I18n.t("punches.form.punched_on_app")
    else; plain(fformat(model, field.key))
    end
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
      div(class: "", data: { controller: "form" }) do
        error_messages
        yield
        div(class: "flex flex-row flex-row-reverse m-5 gap-4") do
          submit(submit_string, tabindex: "0", class: "mort-btn-primary") if @editable
          input(
            type: "reset",
            tabindex: "0",
            class: "mort-btn-cancel"
          ) { helpers.t("cancel") }
        end
        div(class: "h-10") do
          plain "&nbsp;".html_safe
        end
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
end
