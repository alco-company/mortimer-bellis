class PunchClockPunch < PunchClockBase
  attr_accessor :resource, :user, :pane, :tab, :punch_clock

  def initialize(resource:, user: nil, tab: "today")
    @resource = @punch_clock = resource
    @user = user || false
    @tab = tab
  end

  def view_template
    div(class: "h-full w-full") do
      div(class: "sm:p-4 flex flex-col") do
        punch_buttons
        todays_minutes
        div(class: "grid grid-cols-2 gap-5") do
          div() do
            list_punches ".todays_punches", user.todays_punches
          end
          div(class: "h-full ") do
            list_punches ".payroll_punches", user.punches.by_payroll_period(user.punches_settled_at).order(punched_at: :desc), false, true, "payroll"
          end
        end
      end
    end
  end

  def punch_buttons
    div(class: "flex grow-0 items-center justify-center w-full p-5 font-medium rtl:text-right text-gray-500 gap-3") do
      user.archived? ?
        I18n.t("user.archived") :
        render(PunchClockButtons.new(punch_clock: resource, user: user, tab: tab, url:  pos_punch_clock_url))
    end
  end
end
