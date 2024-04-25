class ApplicationForm < Superform::Rails::Form
  include Phlex::Rails::Helpers::Pluralize

  def initialize(model, **options)
    super(model, **options)
    @editable = options[:editable]
  end

  class MultipleSelectField < Superform::Rails::Components::SelectField
    def options(*collection)
      map_options(collection).each do |key, value|
        option(selected: field.value.include?(key), value: key) { value }
      end
    end
  end

  class Field < Field
    def multiple_select(*collection, **attributes, &)
      MultipleSelectField.new(self, attributes: attributes, collection: collection, &)
    end
  end

  def qr_code(component, value)
    div(class: "my-5") do
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
      div(class: "my-5") do
        plain(component.field.value)
      end
    end
  end

  def row(component)
    div(class: "my-5") do
      render(component.field.label) do
        span(class: "font-bold") do
          plain I18n.t("activerecord.attributes.#{component.field.parent.key}.#{component.field.key}")
        end
      end
      @editable ?
        render(component) :
        div(class: "mr-5") do
          plain(component.field.value)
        end
    end
  end

  def around_template(&)
    super do
      error_messages
      yield
      submit(class: "mort-btn-primary mt-5") if @editable
    end
  end

  def error_messages
    if model.errors.any?
      div(style: "color: red;") do
        h2 { I18n.t(:form_errors_prohibited, errors: model.errors.count) }
        ul do
          model.errors.each do |error|
            li { error.full_message }
          end
        end
      end
    end
  end
end
