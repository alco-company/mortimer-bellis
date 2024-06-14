class PosPunches < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  attr_accessor :punches, :folded, :edit, :tab, :punch_clock

  def initialize(punches: [], folded: false, edit: true, tab: "today")
    @punches = punches
    @folded = folded
    @edit = edit
    @tab = tab
  end

  def view_template
    current_date = nil
    employee = punches.first.employee rescue false
    punch_clock = punches.first.punch_clock rescue false
    punches.each do |punch|
      Time.use_zone(employee.time_zone) do
        if punch.punched_at.to_date != current_date
          current_date = punch.punched_at&.to_date
          li(id: "#{tab}_#{(helpers.dom_id punch)}", class: "flex items-center justify-between gap-x-6 py-5") do
            div(class: "grid grid-cols-2 min-w-0 w-full") do
              display_date(punch, employee, punch_clock)
              div(class: "text-right") { display_work(punch.punch_card) }
            end
            div(class: "flex flex-none items-center gap-x-4") do
              render(PosContextmenu.new(resource: punch, punch_clock: punch_clock, employee: employee, list: true, turbo_frame: helpers.dom_id(punch), alter: edit))
            end
          end
        end
        li(id: (helpers.dom_id punch), class: "flex items-center justify-between gap-x-6 py-5") do
          div(class: "min-w-0 w-full grid grid-cols-5 items-center") do
            helpers.render_text_column(value: helpers.tell_state(punch), css: "truncate") +
            helpers.render_text_column(value: punch.comment, css: "hidden md:block col-span-3 truncate") +
            helpers.render_time_column(value: punch.punched_at, css: "text-right")
          end
          div(class: "flex flex-none items-center gap-x-4") do
            render PosContextmenu.new resource: punch, turbo_frame: helpers.dom_id(punch), alter: edit, links: [ pos_employee_edit_url(api_key: employee.access_token, id: punch.id), pos_employee_delete_url(api_key: employee.access_token, id: punch.id) ]
          end
        end unless folded
      end
    end
  end

  def display_date(punch, employee, punch_clock)
    div(class: "flex") do
      span(class: "mr-4") { punch.punched_at.to_date.to_s }
      folded ? 
        link_to(helpers.pos_employee_punches_url(id: punch.id, employee_id: employee&.id, punch_clock_id: punch_clock&.id), data: { turbo_stream: "" }) do
          whitespace
          span(class: "sr-only") { "Get todays punches" }
          whitespace
          svg(
            class: "h-5 w-5",
            fill: "currentColor",
            aria_hidden: "true",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24px",
            viewbox: "0 -960 960 960",
            width: "24px"
          ) do |s|
            s.path(
              d:
                "M480-120 300-300l58-58 122 122 122-122 58 58-180 180ZM358-598l-58-58 180-180 180 180-58 58-122-122-122 122Z"
            )
          end
          whitespace
        end :
        link_to(helpers.pos_employee_url(api_key: employee.access_token, tab: "payroll")) do
          whitespace
          span(class: "sr-only") { "Get todays punches" }
          whitespace
          svg(
            class: "h-5 w-5",
            fill: "currentColor",
            aria_hidden: "true",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24px",
            viewbox: "0 -960 960 960",
            width: "24px"
          ) do |s|
            s.path(
              d:
                "m356-160-56-56 180-180 180 180-56 56-124-124-124 124Zm124-404L300-744l56-56 124 124 124-124 56 56-180 180Z"
            )
          end
          whitespace
        end
    end
  end

  def display_work(punch_card)
    counters = {}
    if punch_card.work_date == Date.current
      counters = punch_card.employee.minutes_today_up_to_now
    else
      counters[:work] = punch_card&.work_minutes || 0
      counters[:break] = punch_card&.break_minutes || 0
    end
    "(%s) %s" % [ helpers.display_hours_minutes(counters[:break]), helpers.display_hours_minutes(counters[:work]) ]
  end
end
