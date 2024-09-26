# frozen_string_literal: true

class PunchButtonComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo

  attr_accessor :user, :state, :punch_clock_id

  def initialize(user:, punch_clock:)
    @user = user
    @state = user&.state || ""
    @punch_clock_id = punch_clock&.id
  end

  def view_template
    div(id: "punch_button", class: "fixed flex gap-x-4 z-20 right-4 bottom-6") do
      case state
      when "out", "break"; punch_in
      when "in"
        punch_break
        punch_out
      end
    end
  end

  def punch_break
    button_to(punches_url, class: "mort-btn-punch-break rounded-full w-14 h-14", data: { turbo_frame: :_top }) do
      input(type: "hidden", name: "punch[punch_clock_id]", value: punch_clock_id)
      input(type: "hidden", name: "punch[state]", value: "break")
      input(type: "hidden", name: "punch[user_id]", value: user&.id)
      plain "break"
    end
  end

  def punch_out
    button_to(punches_url, class: "mort-btn-punch-out rounded-full w-14 h-14", data: { turbo_frame: :_top }) do
      input(type: "hidden", name: "punch[punch_clock_id]", value: punch_clock_id)
      input(type: "hidden", name: "punch[state]", value: "out")
      input(type: "hidden", name: "punch[user_id]", value: user&.id)
      plain "out"
    end
  end

  def punch_in
    button_to(punches_url, class: "mort-btn-punch-in rounded-full w-14 h-14", data: { turbo_frame: :_top }) do
      input(type: "hidden", name: "punch[punch_clock_id]", value: punch_clock_id)
      input(type: "hidden", name: "punch[state]", value: "in")
      input(type: "hidden", name: "punch[user_id]", value: user&.id)
      plain "in"
    end
  end
end
