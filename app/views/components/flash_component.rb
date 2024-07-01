# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  def initialize(flash: [])
    @flash = flash
  end

  def view_template
    # in honor of Tailwind not being able to know 'tags' in advance
    span(class: "hidden mort-flash-info mort-flash-error mort-flash-success mort-flash-warning mort-flash-notice mort-flash-timedout mort-flash-alert")
    #  "Global notification live region, render this permanently at the end of the document"
    div(
      id: "flash_container",
      aria_live: "assertive",
      class: "z-40 pointer-events-none fixed inset-0 flex items-end mb-6 px-4 py-6 sm:items-start sm:p-6"
    ) do
      div(class: "flex w-full flex-col items-center space-y-4 sm:items-end") do
        @flash.each do |type, msg|
          render ToastComponent.new(type: type, message: msg) if msg.class == String
          # flash_message(type, msg) if msg.class == String
          # p(data_controller: "notice", class: "mort-flash-#{type}", id: "flash_#{type}") { msg }
        end
      end
    end if @flash.any?
  end
end
