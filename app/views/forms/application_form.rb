class ApplicationForm < Superform::Rails::Form
  include Phlex::Rails::Helpers::Pluralize

  class MultipleSelectField < Superform::Rails::Components::SelectField
    def options(*collection)
      map_options(collection).each do |key, value|
        option(selected: field.value.include?( key), value: key) { value }
      end
    end
  end

  class Field < Field 
    def multiple_select(*collection, **attributes, &)
      MultipleSelectField.new(self, attributes: attributes, collection: collection, &)
    end    
  end

  def hidden(component)
    div do
      render component
    end
  end

  def row(component)
    div(class: "my-5") do
      render component.field.label do 
        plain I18n.t("activerecord.attributes.#{component.field.parent.key.to_s}.#{component.field.key.to_s}" )
      end
      render component
    end
  end

  def around_template(&)
    super do
      error_messages
      yield
      submit class: "mort-btn-primary mt-5"
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
