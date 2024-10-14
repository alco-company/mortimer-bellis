# frozen_string_literal: true

class TimeMaterialButtonComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :user, :state, :punch_clock_id

  def initialize(user:)
    @user = user
    # @state = user&.state || ""
    # @punch_clock_id = punch_clock&.id
  end

  def view_template
    div(id: "time_material_button", class: "lg:hidden fixed flex px-6 z-20 w-full bottom-6 justify-between right-0 ") do
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
    button_to(punches_url, class: "mort-btn-start-time-material rounded-full w-14 h-14", data: { turbo_frame: :_top }) do
      input(type: "hidden", name: "punch[state]", value: "start")
      input(type: "hidden", name: "punch[user_id]", value: user&.id)
      render Icons::Play.new
    end
  end

  def add_time_material_button
    link_to(new_time_material_url, class: "mort-btn-start-time-material rounded-full w-14 h-14", data: { turbo_frame: "form" }) do
      render Icons::Add.new
    end
  end
end
