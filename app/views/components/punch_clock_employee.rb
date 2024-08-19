class PunchClockEmployee < PunchClockBase
  attr_accessor :employee, :tab, :punch_clock, :edit

  def initialize(employee: nil, tab: "today", edit: false)
    @employee = employee || false
    @punch_clock = nil
    @tab = tab
    @edit = edit
  end

  def view_template
    div(class: "sm:h-full w-full") do
      div(class: "mb-20 sm:mb-2 p-4 pb-18 h-full") do
        case tab
        when "payroll"; show_payroll
        when "profile"; show_profile
        else; show_today
        end
      end
      div(class: "fixed bottom-[103px] z-40 bg-slate-100 opaque-5 w-full") do
        punch_more
      end
      div(class: %(w-full fixed bottom-[39px] z-40 bg-slate-100 opaque-5)) do
        div(class: "max-w-full lg:max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 mb-2") do
          div(class: "border-gray-200 py-2 text-gray-400 justify-items-stretch flex flex-row-reverse gap-2") do
            render PunchClockButtons.new employee: employee, tab: tab, url: helpers.pos_employee_url(api_key: employee.access_token), edit: edit
          end
        end
      end unless tab == "profile"
    end
  end


  def punch_more
    div(class: "flex flex-row flex-wrap text-xs hidden", data: { pos_employee_target: "evenMoreOptions" }) do
      button_tag helpers.t(".child_sick"), type: "submit", form: "inform", class: "bg-red-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
      button_tag helpers.t(".nursing_sick"), type: "submit", form: "inform", class: "bg-red-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
      button_tag helpers.t(".p56_sick"), type: "submit", form: "inform", class: "bg-red-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
      button_tag helpers.t(".loss_work_sick"), type: "submit", form: "inform", class: "bg-red-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
      button_tag helpers.t(".rr_free"), type: "submit", form: "inform", class: "bg-blue-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
      button_tag helpers.t(".senior_free"), type: "submit", form: "inform", class: "bg-blue-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
      button_tag helpers.t(".unpaid_free"), type: "submit", form: "inform", class: "bg-blue-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
      button_tag helpers.t(".maternity_free"), type: "submit", form: "inform", class: "bg-blue-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
      button_tag helpers.t(".leave_free"), type: "submit", form: "inform", class: "bg-blue-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
    end
    div(class: "flex flex-row flex-wrap text-xs hidden", data: { pos_employee_target: "moreOptions" }) do
      button_tag(helpers.t(".even_more_options"), type: "button", data: { action: "click->pos-employee#toggleEvenMoreOptions" }, class: "bg-slate-200 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium")
      button_tag helpers.t(".free"), type: "submit", form: "inform", class: "bg-blue-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
      button_tag helpers.t(".iam_sick"), type: "submit", form: "inform", class: "bg-red-500 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium"
    end
  end
end
