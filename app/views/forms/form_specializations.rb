module FormSpecializations
  extend ActiveSupport::Concern

  included do
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
        included = false
        if fields_include?(key)
          row(field(key.to_sym).input()) && included = true if type.class.to_s =~ /String/
          row(field(key.to_sym).textarea(class: "mort-form-text")) && included = true if type.class.to_s =~ /Text/
          p(class: "hidden") { "missing #{key} - #{type.class}" } unless included
        end
      end
    end

    def fields_include?(key)
      return false unless fields.any?
      fields.include?(key.to_sym) || fields.include?(key)
    end
  end
end
