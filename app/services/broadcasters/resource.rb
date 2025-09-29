class Broadcasters::Resource
  include Turbo::StreamsHelper
  include ActionView::RecordIdentifier

  attr_accessor :tenant, :resource, :resource_class, :resources_stream, :params, :target, :user, :partial

  def initialize(resource, params = {}, target: nil, user: nil, stream: nil, partial: nil)
    @resource = resource
    @params = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params
    @target = target || dom_id(resource)
    @resource_class = resource.class rescue nil
    @user = user || Current.get_user
    @tenant = resource.respond_to?(:tenant) ? resource.tenant : user.tenant rescue nil
    @resources_stream = stream || "%s_%s" % [ tenant&.id, resource_class.to_s.underscore.pluralize ] rescue nil
    @partial = partial || resource
  end

  ## TODO - use Broadcasters::Resource.new(resource)#flash instead of flash[:*] in controllers, elsewhere
  def flash *args
    fl = args[0] || {}
    return unless tenant
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: "flash_container",
      action: :replace,
      partial: "application/flash_message", locals: { tenant: tenant, messages: fl, user: user }
    )
  end

  def create
    return unless tenant
    return unless resource.persisted?
    @target = (@target == dom_id(resource)) ? "record_list" : @target
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: @target,
      action: :prepend,
      partial: partial,
      locals: { resource_class.to_s.underscore => resource, params: params, user: user, target: @target }
    )
  end

  def replace
    return unless tenant
    Turbo::StreamsChannel.broadcast_action_later_to(
      resources_stream,
      target: target,
      action: :replace,
      partial: partial,
      locals: { resource_class.to_s.underscore => resource, params: params, user: user, target: target }
    )
  end

  def destroy
    return unless tenant
    Turbo::StreamsChannel.broadcast_remove_to resources_stream, target: target
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
