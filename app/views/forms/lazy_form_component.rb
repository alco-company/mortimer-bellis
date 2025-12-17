class LazyFormComponent < ApplicationComponent
  def initialize(form_class:, resource:, editable:, fields:, **options)
    @form_class = form_class
    @resource = resource
    @editable = editable
    @fields = fields
    @options = options
  end

  def view_template
    # Defer instantiation of the Superform-derived component until inside
    # an active Phlex rendering context.
    form_instance = @form_class.new(resource: @resource, editable: @editable, fields: @fields, **@options)
    render form_instance
  end
end
