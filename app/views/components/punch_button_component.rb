# frozen_string_literal: true

class PunchButtonComponent < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTo

  attr_accessor :user

  def initialize(user:)
    @user = user
    @color = user.in? ? "mort-btn-punch-out" : "mort-btn-punch-in"
  end

  def view_template
    div do
      button_to "punch", punches_url, class: "fixed z-20 right-4 bottom-6 rounded-full w-14 h-14 #{@color}", data: { turbo_frame: :_top }
    end
  end
end
