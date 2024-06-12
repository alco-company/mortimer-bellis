class PunchClockEmployee < PunchClockBase
  attr_accessor :employee, :tab, :punch_clock

  def initialize(employee: nil, tab: "today", edit: false)
    @employee = employee || false
    @punch_clock = nil
    @tab = tab
    @edit = edit
  end

  def view_template
    div(class: "sm:h-full w-full") do
      div(class: "mb-20 sm:mb-2 sm:p-4 pb-18 h-full") do
        case tab
        when "payroll"; show_payroll
        when "profile"; show_profile
        else; show_today
        end
      end
      div(class: %(w-full fixed bottom-[39px] z-40 bg-slate-100 opaque-5)) do
        div(class: "max-w-full lg:max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 mb-2") do
          div(class: "border-gray-200 py-2 text-gray-400 justify-items-stretch flex flex-row-reverse gap-2") do
            render PunchClockButtons.new employee: employee, tab: tab, url: helpers.pos_employee_url(api_key: employee.access_token)
          end
        end
      end unless tab == "profile"
    end
  end
end
