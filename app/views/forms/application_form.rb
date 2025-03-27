class ApplicationForm < Superform::Rails::Form
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::LinkTo
  include FieldSpecializations
  include FormSpecializations

  attr_accessor :resource, :cancel_url, :title, :edit_url,  :editable, :api_key, :model, :fields

  def initialize(resource:, editable: nil, **options)
    options[:data] ||= { form_target: "form" }
    options[:class] ||= "mort-form"
    super(resource, **options)
    @resource = @model = resource
    @fields = options[:fields] || []
    @fields = @fields.any? ? @fields : model.class.attribute_types.keys
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
end
