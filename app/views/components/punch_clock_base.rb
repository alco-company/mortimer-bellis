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
    div(class: "flex grow-0 w-full p-5 font-medium text-gray-500 gap-3") do
      counters = employee.minutes_today_up_to_now
      render Stats.new title: helpers.t(".stats_title"), stats: [
        { title: helpers.t(".worktime"), value: helpers.display_hours_minutes(counters[:work]) },
        { title: helpers.t(".breaks"), value: helpers.display_hours_minutes(counters[:break]) }
      ]
    end if employee
  end

  def show_payroll
    div(class: "p-4") do
      if @edit
        render(PunchClockManual.new(employee: employee))
      else
        counters = employee.minutes_this_payroll_period rescue []
        counters["work"] ||= 0
        counters["break"] ||= 0
        render Stats.new title: helpers.t(".stats_title"), stats: [
          { title: helpers.t(".worktime"), value: helpers.display_hours_minutes(counters["work"]) },
          { title: helpers.t(".breaks"), value: helpers.display_hours_minutes(counters["break"]) }
        ] if counters.any?
      end

      list_punches ".payroll_punches", employee.punches.by_payroll_period(employee.punches_settled_at).order(punched_at: :desc), true, true, "payroll"
      div(class: "mb-32") { "&nbsp;".html_safe }
    end
  end

  def list_punches(title, punches = [], edit = false, folded = false, tab = "today")
    h4(class: "m-4 text-gray-700 text-xl") { helpers.t(title) }
    div(class: "pb-20 flex-none min-w-full px-4 sm:px-6 md:px-0 scrollbar:!w-1.5 scrollbar:!h-1.5 scrollbar:bg-transparent scrollbar-track:!bg-slate-100 scrollbar-thumb:!rounded scrollbar-thumb:!bg-slate-300 scrollbar-track:!rounded dark:scrollbar-track:!bg-slate-500/[0.16] dark:scrollbar-thumb:!bg-slate-500/50 lg:supports-scrollbars:pr-2") do
      ul(class: "m-4 divide-y divide-gray-100") do
        render PosPunches.new punches: punches, folded: folded, edit: edit, tab: tab
      end
    end
  end

  def show_profile
    render PunchClockProfile.new employee: employee
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
