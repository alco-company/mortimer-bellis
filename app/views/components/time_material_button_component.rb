# frozen_string_literal: true

class TimeMaterialButtonComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::TurboFrameTag

  attr_accessor :user, :state, :punch_clock_id

  def initialize(user:, play: true)
    @user = user
    @play = play
    # @state = user&.state || ""
    # @punch_clock_id = punch_clock&.id
  end

  def view_template
    div(id: "time_material_buttons", class: "lg:hidden fixed flex px-6 z-20 w-full bottom-6 justify-between right-0 ") do
      add_time_material_button
      start_timer_button
      # case state
      # when "out", "break"; punch_in
      # when "in"
      #   punch_break
      #   punch_out
      # end
    end
  end

  def start_timer_button
    button_to(punches_url, class: "mort-btn-punch-in rounded-full w-14 h-14 flex items-center", data: { turbo_frame: :_top }) do
      input(type: "hidden", name: "punch[punch_clock_id]", value: punch_clock_id)
      input(type: "hidden", name: "punch[state]", value: "in")
      input(type: "hidden", name: "punch[user_id]", value: user&.id)
      render Icons::Play.new cls: "h-8 w-8 text-white"
    end

    # button_to(time_materials_url, class: "mort-btn-start-time-material rounded-full w-14 h-14") do
    #   input(type: "hidden", name: "play", value: "start")
    #   @play ? render(Icons::Play.new cls: "text-white bg-sky-600") : render(Icons::Pause.new cls: "text-white bg-sky-600")
    # end
  end

  def add_time_material_button
    link_to(new_time_material_url, class: "mort-btn-start-time-material rounded-full w-14 h-14", data: { turbo_frame: "form" }) do
      render Icons::Add.new cls: "text-white bg-sky-600"
    end
  end
end
