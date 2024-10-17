class Broadcasters::Resource
  include Turbo::StreamsHelper
  include ActionView::RecordIdentifier

  attr_reader :tenant, :resource, :resource_class, :resources_stream

  def initialize(resource)
    @resource = resource
    @resource_class = resource.class rescue nil
    @tenant = resource.respond_to?(:tenant) ? resource.tenant : Current.tenant rescue nil
    @resources_stream = "%s_%s" % [ tenant&.id, @resource_class.to_s.underscore.pluralize ] rescue nil
  end

  def create
    return unless tenant
    return unless resource.persisted?
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: "list",
      action: :prepend,
      partial: resource,
      locals: { resource_class.to_s.underscore => resource }
    )
  end

  def replace
    return unless tenant
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: dom_id(resource),
      action: :replace,
      partial: resource,
      locals: { resource_class.to_s.underscore => resource }
    )
  end

  def destroy
    return unless tenant
    Turbo::StreamsChannel.broadcast_remove_to resources_stream, target: dom_id(resource)
  end

  def destroy_all
    return unless tenant
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: "list",
      action: :replace,
      partial: "empty_record_list",
      locals: { tenant: tenant, resources: [], resource_class: resource_class, list: "#{@resource_class.to_s.underscore.pluralize}/list" }
    )
  end
end
