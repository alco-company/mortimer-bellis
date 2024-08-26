class Broadcasters::Resource
  include Turbo::StreamsHelper
  include ActionView::RecordIdentifier

  attr_reader :resource

  def initialize(resource)
    @resource = resource
  end

  def create
    Turbo::StreamsChannel.broadcast_action_later_to(
      :holidays,
      target: :append_new,
      action: :prepend,
      partial: "holidays/holiday",
      locals: { holiday: @resource }
    )
  end

  def replace
    Turbo::StreamsChannel.broadcast_action_later_to(
      :holidays,
      target: dom_id(@resource),
      action: :replace,
      partial: "holidays/holiday",
      locals: { holiday: @resource }
    )
  end

  def destroy
    Turbo::StreamsChannel.broadcast_remove_to "holidays", target: "holiday_#{@resource.id}"
  end
end
