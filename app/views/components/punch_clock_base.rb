class PunchClockBase < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField
  include Phlex::Rails::Helpers::ButtonTag

  attr_accessor :employee, :tab

  def initialize(employee: nil, tab: "today", edit: false)
    @employee = employee || false
    @tab = tab
    @edit = edit
  end

  def view_template
    div(class: "h-full w-full") do
      div(class: "sm:p-4 pb-18 h-full") do
        case tab
        when "payroll"; show_payroll
        when "profile"; show_profile
        else; show_today
        end
      end
      render PunchClockButtons.new employee: employee, tab: tab
    end
  end

  def show_today
    todays_minutes
    list_punches ".todays_punches", employee.todays_punches
    div(class: "mb-32") { " " }
  end

  def todays_minutes
    div(class: "flex w-full p-5 font-medium text-gray-500 gap-3") do
      counters = employee.minutes_today_up_to_now
      render Stats.new title: helpers.t(".stats_title"), stats: [
        { title: helpers.t(".worktime"), value: helpers.display_hours_minutes(counters[:work]) },
        { title: helpers.t(".breaks"), value: helpers.display_hours_minutes(counters[:break]) }
      ]
    end if employee
  end

  def show_payroll
    div(class: "p-4") do
      render PunchClockManual.new(employee: employee) if @edit
      list_punches ".payroll_punches", employee.punches.by_payroll_period(employee.punches_settled_at).order(punched_at: :desc), true
      div(class: "mb-32") { "&nbsp;".html_safe }
    end
  end

  def list_punches(title, punches = [], edit = false, folded = false, tab = "today")
    h4(class: "m-4 text-gray-700 text-xl") { helpers.t(title) }
    ul(class: "m-4 mb-32 divide-y divide-gray-100") do
      current_date = nil
      punches.each do |punch|
        if punch.punched_at.to_date != current_date
          current_date = punch.punched_at&.to_date
          li(id: "#{tab}_#{(helpers.dom_id punch)}", class: "flex items-center justify-between gap-x-6 py-5") do
            div(class: "min-w-0 w-full columns-2") do
              span { helpers.render_date_column(value: punch.punched_at, css: "font-medium") }
            end
            div(class: "flex flex-none items-center gap-x-4") do
              folded ?
                render(PosContextmenu.new(resource: punch, punch_clock: punch_clock, employee: employee, list: true, turbo_frame: helpers.dom_id(punch), alter: edit, folded: true)) :
                render(PosContextmenu.new(resource: punch, punch_clock: punch_clock, employee: employee, list: true, turbo_frame: helpers.dom_id(punch), alter: edit))
            end
          end
        end
        li(
          id: (helpers.dom_id punch),
          class: "flex items-center justify-between gap-x-6 py-5"
        ) do
          div(class: "min-w-0 w-full columns-2") do
            span { helpers.render_text_column(value: helpers.tell_state(punch), css: "text-right") }
            span { helpers.render_time_column(value: punch.punched_at, css: "") }
          end
          div(class: "flex flex-none items-center gap-x-4") do
            render PosContextmenu.new resource: punch, turbo_frame: helpers.dom_id(punch), alter: edit, links: [ pos_employee_edit_url(api_key: employee.access_token, id: punch.id), pos_employee_delete_url(api_key: employee.access_token, id: punch.id) ]
          end
        end unless folded
      end
    end
  end

  def show_profile
    render PunchClockProfile.new employee: employee
    div(class: "mb-32") { " " }
  end

  def show_today_old
    div(class: "w-full") do
      h2(class: "text-gray-700 text-xl") { helpers.t(".todays_punches") }
      # div( class: "mb-4 text-gray-700 text-xl") { helpers.t(".for_employee", name: employee.name) }
      div(class: "font-mono") do
        ul do
          employee.todays_punches.each do |punch|
            li(
              id: (helpers.dom_id punch),
              class: "flex items-center justify-between gap-x-6 py-5"
            ) do
              div(class: "min-w-0 w-full columns-2 text-gray-700 text-xl") do
                span { helpers.render_datetime_column(field: punch.punched_at, css: "") }
                span { helpers.render_text_column(field: punch.state, css: "text-right") }
              end
              div(class: "flex flex-none items-center gap-x-4") do
                helpers.render_contextmenu resource: punch
              end
            end
          end
        end
      end
    end
  end
end
