class PunchClockBase < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField
  include Phlex::Rails::Helpers::ButtonTag

  attr_accessor :user, :tab

  def initialize(user: nil, tab: "today", edit: false)
    @user = user || false
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
      render PunchClockButtons.new user: employee, tab: tab
    end
  end

  def show_today
    todays_minutes
    list_punches ".todays_punches", user.todays_punches
    div(class: "mb-32") { " " }
  end

  def todays_minutes
    div(class: "flex grow-0 w-full p-5 font-medium text-gray-500 gap-3") do
      counters = user.minutes_today_up_to_now
      render Stats.new title: helpers.t(".stats_title"), stats: [
        { title: helpers.t(".worktime"), value: helpers.display_hours_minutes(counters[:work]) },
        { title: helpers.t(".breaks"), value: helpers.display_hours_minutes(counters[:break]) }
      ]
    end if employee
  end

  def show_payroll
    div(class: "p-4") do
      if @edit
        render(PunchClockManual.new(user: employee))
      else
        counters = user.minutes_this_payroll_period rescue []
        counters["work"] ||= 0
        counters["break"] ||= 0
        render Stats.new title: helpers.t(".stats_title"), stats: [
          { title: helpers.t(".worktime"), value: helpers.display_hours_minutes(counters["work"]) },
          { title: helpers.t(".breaks"), value: helpers.display_hours_minutes(counters["break"]) }
        ] if counters.any?
      end

      list_punches ".payroll_punches", user.punches.by_payroll_period(user.punches_settled_at).order(punched_at: :desc), true, true, "payroll"
      div(class: "mb-32") { "&nbsp;".html_safe }
    end
  end

  def list_punches(title, punches = [], edit = false, folded = false, tab = "today")
    h4(class: "m-0 md:m-4 mt-4 text-gray-700 text-xl") { helpers.t(title) }
    div(class: "pb-20 flex-none min-w-full px-0 scrollbar:!w-1.5 scrollbar:!h-1.5 scrollbar:bg-transparent scrollbar-track:!bg-slate-100 scrollbar-thumb:!rounded scrollbar-thumb:!bg-slate-300 scrollbar-track:!rounded dark:scrollbar-track:!bg-slate-500/[0.16] dark:scrollbar-thumb:!bg-slate-500/50 lg:supports-scrollbars:pr-2") do
      ul(class: "m-0 md:m-4 divide-y divide-gray-100") do
        render PosPunches.new punches: punches, folded: folded, edit: edit, tab: tab
      end
    end
  end

  def show_profile
    render PunchClockProfile.new user: employee
  end
end
