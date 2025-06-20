class Settings::Setting < ApplicationComponent
  include Phlex::Rails::Helpers::TurboStreamFrom
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(resource:, user:, params: {}, target: nil)
    @resource = resource
    @user = user
    @params = params
    @target = target || "settings_#{resource.id}"
  end

  def view_template
    case @params["type"]
    when "boolean"; true_false
    when "text";    text_box
    when "options";  select_input
    when "color";   color_input
    end
  end

  def true_false
    url = "/settings/#{@resource.id}"
    render ToggleButton.new(
      resource: @resource,
      label: "toggle",
      value: @resource.value,
      target: @target,
      url: url,
      action: "click->boolean#toggle",
      attributes: {}
    )
  end

  def text_box
    url = "/settings/#{@resource.id}"
    render TextBox.new(
      resource: @resource,
      value: @resource.value,
      target: @target,
      url: url,
      state: "show",
      hint: @resource.description,
      attributes: { class: "flex col-span-2 grow" },
    )
  end
end
