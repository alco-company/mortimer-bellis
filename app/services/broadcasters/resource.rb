class Broadcasters::Resource
  include Turbo::StreamsHelper
  include ActionView::RecordIdentifier

  attr_reader :resource, :resource_class, :resources_stream

  def initialize(resource)
    @resource = resource
    @resource_class = resource.class
    @resources_stream = "%s_%s" % [ Current.account.id, @resource_class.to_s.underscore.pluralize ]
  end

  def create
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: :append_new,
      action: :prepend,
      partial: resource,
      locals: { resource_class.to_s.underscore => resource }
    )
  end

  def replace
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: dom_id(resource),
      action: :replace,
      partial: resource,
      locals: { resource_class.to_s.underscore => resource }
    )
  end

  def destroy
    Turbo::StreamsChannel.broadcast_remove_to resources_stream, target: dom_id(resource)
  end
end
