# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  def initialize(flash: [])
    @flash = flash
  end

  def view_template
    # in honor of Tailwind not being able to know 'tags' in advance
    span(class: "hidden mort-flash-info mort-flash-error mort-flash-success mort-flash-warning mort-flash-notice mort-flash-timedout mort-flash-alert")
    flash_container if @flash.any?
  end

  def flash_container
    #  "Global notification live region, render this permanently at the end of the document"
    div(
      id: "flash_container",
      aria_live: "assertive",
      class: "z-40 pointer-events-none fixed inset-0 flex items-end mb-6 px-4 py-6 sm:items-start sm:p-6"
    ) do
      div(class: "flex w-full flex-col items-center space-y-4 sm:items-end") do
        @flash.each do |type, msg|
          flash_message(type, msg) if msg.class == String
          # p(data_controller: "notice", class: "mort-flash-#{type}", id: "flash_#{type}") { msg }
        end
      end
    end
  end

  # @apply fixed z-40 left-12 bottom-10 mb-5 py-2 px-3 font-medium rounded-sm inline-block bg-yellow-100 border border-yellow-400 text-yellow-700;
  def flash_message(type, msg, title = "")
    # %(Notification panel, dynamically insert this into the live region when it needs to be displayed
    # Entering: "transform ease-out duration-300 transition"
    #   From: "translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
    #   To: "translate-y-0 opacity-100 sm:translate-x-0"
    # Leaving: "transition ease-in duration-100"
    #   From: "opacity-100"
    #   To: "opacity-0")
    div(
      data_controller: "notice",
      class:
        "pointer-events-auto w-full max-w-sm overflow-hidden rounded-lg mort-flash-#{type} mort-flash-border-#{type} shadow-lg ring-1 ring-black ring-opacity-5"
    ) do
      div(class: "p-4") do
        div(class: "flex items-start") do
          div(class: "flex-shrink-0 mort-flash-#{type} ") do
            icon(type)
          end
          div(class: "ml-3 w-0 flex-1 pt-0.5") do
            p(class: "text-sm font-medium mort-flash-#{type} ") do
              plain title
            end
            p(class: "mt-1 text-sm  mort-flash-#{type} ") do
              plain msg
            end
          end
          div(class: "ml-4 flex flex-shrink-0") do
            button(
              type: "button",
              class:
                "inline-flex rounded-md mort-flash-#{type} hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-sky-600 focus:ring-offset-2"
            ) do
              span(class: "sr-only") { "Close" }
              icon("close")
            end
          end
        end
      end
    end
  end

  def icon(type)
    case type
    when "close";     svg(class: "h-5 w-5", fill: "currentColor", viewbox: "0 0 20 20", aria_hidden: "true") do |s| s.path(d: "M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z") end
    when "info";      svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s| s.path(d: "M440-280h80v-240h-80v240Zm40-320q17 0 28.5-11.5T520-640q0-17-11.5-28.5T480-680q-17 0-28.5 11.5T440-640q0 17 11.5 28.5T480-600Zm0 520q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm0-80q134 0 227-93t93-227q0-134-93-227t-227-93q-134 0-227 93t-93 227q0 134 93 227t227 93Zm0-320Z") end
    when "error";     svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s| s.path(d: "M480-280q17 0 28.5-11.5T520-320q0-17-11.5-28.5T480-360q-17 0-28.5 11.5T440-320q0 17 11.5 28.5T480-280Zm-40-160h80v-240h-80v240Zm40 360q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm0-80q134 0 227-93t93-227q0-134-93-227t-227-93q-134 0-227 93t-93 227q0 134 93 227t227 93Zm0-320Z") end
    when "success";   svg(class: "h-6 w-6 text-green-500", fill: "none", viewbox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", aria_hidden: "true") do |s| s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z") end
    when "warning";   svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s| s.path(d: "m40-120 440-760 440 760H40Zm138-80h604L480-720 178-200Zm302-40q17 0 28.5-11.5T520-280q0-17-11.5-28.5T480-320q-17 0-28.5 11.5T440-280q0 17 11.5 28.5T480-240Zm-40-120h80v-200h-80v200Zm40-100Z") end
    when "notice";    svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s| s.path(d: "m320-240 160-122 160 122-60-198 160-114H544l-64-208-64 208H220l160 114-60 198ZM480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm0-80q134 0 227-93t93-227q0-134-93-227t-227-93q-134 0-227 93t-93 227q0 134 93 227t227 93Zm0-320Z") end
    when "timedout";  svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s| s.path(d: "M440-280h80v-240h-80v240Zm40-320q17 0 28.5-11.5T520-640q0-17-11.5-28.5T480-680q-17 0-28.5 11.5T440-640q0 17 11.5 28.5T480-600Zm0 520q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm0-80q134 0 227-93t93-227q0-134-93-227t-227-93q-134 0-227 93t-93 227q0 134 93 227t227 93Zm0-320Z") end
    when "alert";     svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s| s.path(d: "m40-120 440-760 440 760H40Zm138-80h604L480-720 178-200Zm302-40q17 0 28.5-11.5T520-280q0-17-11.5-28.5T480-320q-17 0-28.5 11.5T440-280q0 17 11.5 28.5T480-240Zm-40-120h80v-200h-80v200Zm40-100Z") end
    else;             svg(xmlns: "http://www.w3.org/2000/svg", height: "24px", viewBox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s| s.path(d: "M440-280h80v-240h-80v240Zm40-320q17 0 28.5-11.5T520-640q0-17-11.5-28.5T480-680q-17 0-28.5 11.5T440-640q0 17 11.5 28.5T480-600Zm0 520q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm0-80q134 0 227-93t93-227q0-134-93-227t-227-93q-134 0-227 93t-93 227q0 134 93 227t227 93Zm0-320Z") end
    end
  end

  def type_color(type)
    case type
    when "close";     "mort-flash-close"
    when "info";      "mort-flash-info"
    when "error";     "mort-flash-error"
    when "success";   "mort-flash-success"
    when "warning";   "mort-flash-warning"
    when "notice";    "mort-flash-notice"
    when "timedout";  "mort-flash-timedout"
    when "alert";     "mort-flash-alert"
    else;             "mort-flash-notice"
    end
  end
end
