class ApplicationForm < Superform::Rails::Form
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :editable, :api_key, :resource

  def initialize(model, **options)
    options[:data] = { form_target: "form" }
    options[:class] = "mort-form"
    super(model, **options)
    @resource = model
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
      div(class: attributes[:class], data: { controller: "boolean" }) do
        input(name: dom.name, data: { boolean_target: "input" }, type: :hidden, value: setValue)
        button(
          type: "button",
          data: { action: (attributes[:disabled] ? "" : "click->boolean#toggle"), boolean_target: "button" },
          class:
            "group relative inline-flex h-5 w-10 flex-shrink-0 cursor-pointer items-center justify-center rounded-full focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2",
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
  #           plain builder.label(class: "border-2 border-transparent rounded-full block py-1 px-2 peer-checked:bg-blue-500 peer-checked:text-white hover:bg-blue-200 hover:border-blue-500")
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
      input(**attributes, value: field.value&.strftime("%Y-%m-%d"))
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
    when /tenant_id$/; plain(model&.tenant.name)
    when /team_id$/; div(class: "flex") { link_to(model&.team.name, team_url(model&.team), class: "flex place-items-center truncate mort-btn-secondary") } # plain(model&.team.name)
    when /user_id$/; plain(model&.user.name)
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
      div(class: "") do
        error_messages
        yield
        div(class: "flex flex-row flex-row-reverse m-5 gap-4") do
          if @editable
            submit(submit_string, tabindex: "0", class: "mort-btn-primary")
            button(
              type: "button",
              data: { action: "click->form#clearForm" },
              tabindex: "0",
              class: "mort-btn-cancel"
            ) { helpers.t("cancel") }
          end
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
