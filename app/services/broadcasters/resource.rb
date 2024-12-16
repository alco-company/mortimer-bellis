class Broadcasters::Resource
  include Turbo::StreamsHelper
  include ActionView::RecordIdentifier

  attr_reader :tenant, :resource, :resource_class, :resources_stream, :params, :target, :user, :partial

  def initialize(resource, params = {}, target = "record_list", user = Current.user, stream = nil, partial = nil)
    @resource = resource
    @params = params
    @target = target
    @resource_class = resource.class rescue nil
    @tenant = resource.respond_to?(:tenant) ? resource.tenant : Current.tenant rescue nil
    @user = user
    @resources_stream = stream || "%s_%s" % [ tenant&.id, @resource_class.to_s.underscore.pluralize ] rescue nil
    @partial = partial || resource
  end

  def create
    return unless tenant
    return unless resource.persisted?
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: target,
      action: :prepend,
      partial: partial,
      locals: { resource_class.to_s.underscore => resource, params: params, user: user }
    )
  end

  def replace
    return unless tenant
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: dom_id(resource),
      action: :replace,
      partial: partial,
      locals: { resource_class.to_s.underscore => resource, params: params, user: user }
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
