class PosPunches < ApplicationComponent
  attr_accessor :punches, :folded, :edit, :tab, :punch_clock

  def initialize(punches: [], folded: false, edit: true, tab: "today")
    @punches = punches
    @folded = folded
    @edit = edit
    @tab = tab
  end

  def view_template
    ppp
    # current_date = nil
    # employee = @punches.first.employee
    # @punches.each do |punch|
    #   if punch.punched_at.to_date != current_date
    #     current_date = punch.punched_at&.to_date
    #     li(id: "payroll_#{(helpers.dom_id punch)}", class: "flex items-center justify-between gap-x-6 py-5") do
    #       div(class: "min-w-0 w-full columns-2") do
    #         span { helpers.render_date_column(value: punch.punched_at, css: "font-medium") }
    #       end
    #       div(class: "flex flex-none items-center gap-x-4") do
    #         render(PosContextmenu.new(resource: punch, list: true, turbo_frame: helpers.dom_id(punch), alter: true))
    #       end
    #     end
    #   end
    #   li(
    #     id: (helpers.dom_id punch),
    #     class: "flex items-center justify-between gap-x-6 py-5"
    #   ) do
    #     div(class: "min-w-0 w-full columns-2") do
    #       span { helpers.render_text_column(value: helpers.tell_state(punch), css: "text-right") }
    #       span { helpers.render_time_column(value: punch.punched_at, css: "") }
    #     end
    #     div(class: "flex flex-none items-center gap-x-4") do
    #       render PosContextmenu.new resource: punch, turbo_frame: helpers.dom_id(punch), alter: false, links: [ pos_employee_edit_url(api_key: employee.access_token, id: punch.id), pos_employee_delete_url(api_key: employee.access_token, id: punch.id) ]
    #     end
    #   end
    # end
  end

  def ppp
    current_date = nil
    employee = punches.first.employee
    punch_clock = punches.first.punch_clock
    punches.each do |punch|
      Time.use_zone(employee.time_zone) do
        if punch.punched_at.to_date != current_date
          current_date = punch.punched_at&.to_date
          li(id: "#{tab}_#{(helpers.dom_id punch)}", class: "flex items-center justify-between gap-x-6 py-5") do
            div(class: "grid grid-cols-2 min-w-0 w-full") do
              helpers.render_date_column(value: punch.punched_at, css: "font-medium") +
              helpers.render_text_column(value: display_work(punch.punch_card), css: "text-right")
            end
            div(class: "flex flex-none items-center gap-x-4") do
              folded ?
                render(PosContextmenu.new(resource: punch, punch_clock: punch_clock, employee: employee, list: true, turbo_frame: helpers.dom_id(punch), alter: edit, folded: true)) :
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

  def display_work(punch_card)
    work_time = punch_card&.work_minutes || 0
    break_time = punch_card&.break_minutes || 0
    "(%s) %s" % [ helpers.display_hours_minutes(break_time), helpers.display_hours_minutes(work_time) ]
  end
end
