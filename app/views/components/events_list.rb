class EventsList < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  attr_reader :request, :platform, :date, :view, :calendar

  def initialize(date:, calendar:, view:, &block)
    @date = date
    @calendar = calendar
    @view = view
    @any = false
  end

  def view_template(&block)
    ul(class: "space-y-4") do
      holidays
      punch_list
      event_list
      li { "" } unless @any
    end
  end

  #
  # holidays, more
  def holidays
    Holiday.today(date).each do |holiday|
      @any=true
      li(class: "flex items-center p-1") do
        div(class: "flex flex-col flex-grow truncate") do
          div(class: "text-xs text-violet-600 font-thin flex justify-start items-center") do
            svg(
              class: "pr-1 text-violet-600",
              xmlns: "http://www.w3.org/2000/svg",
              height: "24px",
              viewbox: "0 -960 960 960",
              width: "24px",
              fill: "currentColor"
            ) do |s|
              s.path(
                d:
                  "m80-80 200-560 360 360L80-80Zm132-132 282-100-182-182-100 282Zm370-246-42-42 224-224q32-32 77-32t77 32l24 24-42 42-24-24q-14-14-35-14t-35 14L582-458ZM422-618l-42-42 24-24q14-14 14-34t-14-34l-26-26 42-42 26 26q32 32 32 76t-32 76l-24 24Zm80 80-42-42 144-144q14-14 14-35t-14-35l-64-64 42-42 64 64q32 32 32 77t-32 77L502-538Zm160 160-42-42 64-64q32-32 77-32t77 32l64 64-42 42-64-64q-14-14-35-14t-35 14l-64 64ZM212-212Z"
              )
            end
            div(class: "pr-1") { t(".holyday") }
            div(class: "") { l(@date, format: :day_name) } # "fredag"
            div(class: "") { ", %s" % l(@date, format: :day_month) } # "5. maj"
            div(class: "") { ", %s" % l(@date, format: :year) } # "1945"
            div(class: "pr-1") { ", %s" % l(@date, format: :week_string) } # "uge 26"
          end
          div(class: "grid grid-flow-col") do
            p(class: "truncate") { holiday.name }
          end
        end
        div(class: "flex-grow-0") do
          link_to(holiday_url(holiday)) do
            svg(
              class: "text-gray-300",
              xmlns: "http://www.w3.org/2000/svg",
              height: "24px",
              viewbox: "0 -960 960 960",
              width: "24px",
              fill: "currentColor"
            ) do |s|
              s.path(
                d:
                  "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
              )
            end
          end
        end
      end
    end
  end

  #
  # punches from the punch_card
  def punch_list
    if calendar.calendarable.punch_cards.today(date).any?
      @any=true
      li(class: "flex items-center p-1") do
        div(class: "flex flex-col flex-grow truncate") do
          div(
            class: "text-xs font-thin flex justify-start items-center"
          ) do
            whitespace
            svg(
              class: "pr-1 text-sky-600",
              xmlns: "http://www.w3.org/2000/svg",
              height: "24px",
              viewbox: "0 -960 960 960",
              width: "24px",
              fill: "currentColor"
            ) do |s|
              s.path(
                d:
                  "M200-80q-33 0-56.5-23.5T120-160v-480q0-33 23.5-56.5T200-720h40v-200h480v200h40q33 0 56.5 23.5T840-640v480q0 33-23.5 56.5T760-80H200Zm120-640h320v-120H320v120ZM200-160h560v-480H200v480Zm280-40q83 0 141.5-58.5T680-400q0-83-58.5-141.5T480-600q-83 0-141.5 58.5T280-400q0 83 58.5 141.5T480-200Zm0-60q-58 0-99-41t-41-99q0-58 41-99t99-41q58 0 99 41t41 99q0 58-41 99t-99 41Zm46-66 28-28-54-54v-92h-40v108l66 66Zm-46-74Z"
              )
            end
            div(class: "pr-4 text-sky-600 font-mono") { t("punches.punches") }
            # div(class: "pr-1") { "torsdag" }
            # div(class: "pr-1") { "uge 30" }
            # div(class: "pr-1") { "20. september" }
            # div(class: "pr-1") { "2024" }
          end
          ul(class: "text-xs space-y-1") do
            if calendar.calendarable_type == "Team"
              li(class: "grid grid-cols-6 gap-x-1") do
                div(class: "col-span-1 place-self-end font-mono") { calendar.calendarable.users.count }
                div(class: "col-span-5 ") { t("calendar.users_has_punched_total_punches", count: Punch.where(punch_card_id: calendar.calendarable.punch_cards.today(date).map(&:id)).count) }
              end
            else
              calendar.calendarable.punch_cards.today(date).each do |punch_card|
                punch_card.punches.each do |punch|
                  li(class: "grid grid-cols-6 gap-x-1") do
                    div(class: "place-self-end font-mono") { l(punch.punched_at, format: :ultra_short) }
                    div { WORK_STATE_H[punch.state] }
                    div(class: "col-span-3 truncate") { punch.comment }
                  end
                end
              end
            end
          end
        end
        div(class: "flex-grow-0") do
          link_to(punch_cards_url) do
            svg(
              class: "text-gray-300",
              xmlns: "http://www.w3.org/2000/svg",
              height: "24px",
              viewbox: "0 -960 960 960",
              width: "24px",
              fill: "currentColor"
            ) do |s|
              s.path(
                d:
                  "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
              )
            end
          end
        end
      end
    end
  end

  #
  # hele dagen
  def event_list
    calendar_events do |event, tz|
      if event.occurs?({ from: date.beginning_of_week.to_time, to: date.end_of_week.to_time }, date, tz)
      # all_day_event(event) if event.all_day?
      # when event.event_metum.present?; recurring_event(event)
      # else
      # end
      @any=true
      regular_event(event)
      end
    end
  end

  def events?(dt, &block)
    calendar_events do |event, tz|
      if event.occurs?({ from: dt, to: dt }, dt, tz)
        yield event
      end
    end
  end

  # calendars.each do |calendar|
  # end
  def calendar_events(&block)
    tz = calendar.time_zone
    calendar.events.each do |event|
      yield event, tz
    end
  end

  def all_day_event(event)
    li(class: "flex items-center p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(class: "text-xs font-thin") do
          span(class: "text-amber-500") { "hele dagen" }
          span { "torsdag" }
          span { "uge 30" }
          span { "20. september asd asd " }
          span { "2024" }
        end
        div(class: "grid grid-flow-col") do
          p(class: "truncate") { event.name }
        end
      end
      div(class: "") do
        whitespace
        svg(
          class: "text-gray-300",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24px",
          viewbox: "0 -960 960 960",
          width: "24px",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
          )
        end
      end
    end
  end

  def recurring_event(event)
    # recurring event
    li(class: "flex items-center p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(
          class:
            "grid grid-flow-col items-center justify-start text-xs font-thin"
        ) do
          whitespace
          svg(
            class: "pr-1 text-sky-400",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24px",
            viewbox: "0 -960 960 960",
            width: "24px",
            fill: "currentColor"
          ) do |s|
            s.path(
              d:
                "M200-80q-33 0-56.5-23.5T120-160v-560q0-33 23.5-56.5T200-800h40v-80h80v80h320v-80h80v80h40q33 0 56.5 23.5T840-720v240h-80v-80H200v400h280v80H200ZM760 0q-73 0-127.5-45.5T564-160h62q13 44 49.5 72T760-60q58 0 99-41t41-99q0-58-41-99t-99-41q-29 0-54 10.5T662-300h58v60H560v-160h60v57q27-26 63-41.5t77-15.5q83 0 141.5 58.5T960-200q0 83-58.5 141.5T760 0ZM200-640h560v-80H200v80Zm0 0v-80 80Z"
            )
          end
          whitespace
          span(class: "pr-1") { "08.00 - 14:45" }
          whitespace
          span(class: "pr-1 text-sky-400 font-bold") { "torsdag" }
          whitespace
          span(class: "pr-1") { "uge 30" }
          whitespace
          span(class: "pr-1") { "20. september" }
          whitespace
          span(class: "pr-1") { "2024" }
        end
        div(class: "grid grid-flow-col") do
          p(class: "truncate") { event.name }
        end
      end
      div do
        whitespace
        svg(
          class: "text-gray-300",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24px",
          viewbox: "0 -960 960 960",
          width: "24px",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
          )
        end
      end
    end
  end

  def regular_event(event)
    # almindelig m/kort tekst
    li(class: "flex items-center p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(class: "text-xs font-thin") do
          whitespace
          span { "08.00 - 14:45" }
          whitespace
          span { "torsdag" }
          whitespace
          span { "uge 30" }
          whitespace
          span { "20. september" }
          whitespace
          span { "2024" }
        end
        div(class: "grid grid-flow-col") do
          p(class: "truncate") { event.name }
        end
      end
      div(class: "flex-grow-0") do
        link_to(new_modal_url(id: event.id, modal_form: "event", resource_class: "event", step: "edit", view: view, date: date),
            data: { turbo_stream: true },
            role: "menuitem",
            tabindex: "-1") do
              svg(class: "text-gray-300", xmlns: "http://www.w3.org/2000/svg", height: "24px", viewbox: "0 -960 960 960", width: "24px", fill: "currentColor") do |s|
                s.path(d: "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z")
              end
        end
      end
    end
  end
end
