# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  def initialize(flash: [])
    @flash = flash
  end

  def view_template
    # in honor of Tailwind not being able to know 'tags' in advance
    span(class: "hidden mort-flash-info mort-flash-error mort-flash-success mort-flash-warning mort-flash-notice mort-flash-timedout mort-flash-alert")
    @flash.each do |type, msg|
      p(data_controller: "notice", class: "mort-flash-#{type}", id: "flash_#{type}") { msg }
    end
  end
end
