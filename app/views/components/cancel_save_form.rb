# frozen_string_literal: true

class CancelSaveForm < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::T

  attr_accessor :cancel_url, :title, :edit_url

  def initialize(cancel_url:, title:, edit_url: nil)
    @cancel_url = cancel_url
    @title = title
    @edit_url = edit_url
  end

  def view_template
    cancel_button
    h2(
      id: "slide-over-heading",
      class: "text-base font-semibold leading-6 text-gray-900"
    ) { title }

    div(class: "ml-3 flex h-6 items-center") do
      edit_url ? edit_button : save_button
    end
  end

  private

  def cancel_button
    link_to(
      cancel_url,
      id: "cancel-form",
      class:
        "relative rounded-md bg-white text-gray-400 hover:text-gray-500 focus:ring-1 focus:ring-sky-200",
      role: "link",
      data: {
        form_target: "cancelForm",
        turbo_action: "replace",
        turbo_frame: "form"
      },
      tabindex: "-1"
    ) do
      span(class: "pointer-events-none absolute -inset-2.5")
      span(class: "pointer-events-none sr-only") { "Go back to List" }
      render Icons::Cancel.new cls: "h-6 w-6 text-gray-400"
    end
  end

  def edit_button
    div(class: "ml-3 flex h-6 items-center") do
      edit_url == "-1" ? plain(" ") :
      link_to(
        edit_url,
        class:
          "relative rounded-md bg-white text-gray-400 hover:text-gray-500 focus:ring-1 focus:ring-sky-200",
        role: "link",
        data: {
          turbo_action: "advance",
          turbo_frame: "form"
        },
        tabindex: "-1"
      ) do
        span(class: "pointer-events-none absolute -inset-2.5")
        span(class: "pointer-events-none sr-only") { "Save content" }
        render Icons::Edit.new cls: "text-sky-600 pointer-events-none"
      end
    end
  end

  def save_button
    button(
      type: "button",
      data_action: " click->form#submitForm",
      class:
        "relative rounded-md bg-white text-gray-400 hover:text-gray-500 focus:ring-1 focus:ring-sky-200"
    ) do
      span(class: "absolute -inset-2.5")
      span(class: "sr-only") { "Save content" }
      render Icons::Checkmark.new cls: "h-6 w-6 text-green-500"
    end
  end
end
