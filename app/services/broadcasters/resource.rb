class Broadcasters::Resource
  include Turbo::StreamsHelper
  include ActionView::RecordIdentifier

  attr_reader :account, :resource, :resource_class, :resources_stream

  def initialize(resource)
    @resource = resource
    @resource_class = resource.class
    @account = resource.respond_to?(:account) ? resource.account : Current.account rescue nil
    @resources_stream = "%s_%s" % [ account&.id, @resource_class.to_s.underscore.pluralize ]
  end

  def create
    return unless account
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: :append_new,
      action: :prepend,
      partial: resource,
      locals: { resource_class.to_s.underscore => resource }
    )
  end

  def replace
    return unless account
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: dom_id(resource),
      action: :replace,
      partial: resource,
      locals: { resource_class.to_s.underscore => resource }
    )
  end

  def destroy
    return unless account
    Turbo::StreamsChannel.broadcast_remove_to resources_stream, target: dom_id(resource)
  end

  def destroy_all
    return unless account
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: "list",
      action: :replace,
      partial: "empty_record_list",
      locals: { account: account, resources: [], resource_class: resource_class, list: "#{@resource_class.to_s.underscore.pluralize}/list" }
    )
  end
end
