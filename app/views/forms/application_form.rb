class ApplicationForm < Superform::Rails::Form
  include Phlex::Rails::Helpers::Pluralize

  def initialize(model, **options)
    super(model, **options)
    @editable = options[:editable]
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
    def multiple_select(*collection, **attributes, &)
      MultipleSelectField.new(self, attributes: attributes, collection: collection, &)
    end
    def enum_select(*collection, **attributes, &)
      EnumSelectField.new(self, attributes: attributes, collection: collection, &)
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
        plain(fformat(model, component.field.key))
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
          plain(fformat(model, component.field.key))
        end
    end
  end

  def fformat(model, key)
    case model.field_formats(key)
    when :date; model.send(key).strftime("%d-%m-%Y") rescue nil
    when :time; model.send(key).strftime("%H:%M") rescue nil
    when :boolean; model.send(key) ? I18n.t(:yes) : I18n.t(:no)
    when :association; eval("model.#{key}")
    else; model.send key
    end
  end

  def around_template(&)
    super do
      error_messages
      yield
      submit(submit_string, class: "mort-btn-primary mt-5") if @editable
    end
  end

  def submit_string
    model.new_record? ? I18n.t(:create) : I18n.t(:update)
  end

  def error_messages
    if model.errors.any?
      div(id: "error_explanation", class: "mt-4") do
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
