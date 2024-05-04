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
  end

  class Field < Field
    def multiple_select(*collection, **attributes, &)
      MultipleSelectField.new(self, attributes: attributes, collection: collection, &)
    end
    def enum_select(*collection, **attributes, &)
      EnumSelectField.new(self, attributes: attributes, collection: collection, &)
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
        plain(component.field.value)
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
