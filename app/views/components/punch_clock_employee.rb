class PunchClockEmployee < PunchClockBase
  attr_accessor :user, :tab, :punch_clock, :edit

  def initialize(user: nil, tab: "today", edit: false)
    @user = user || false
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
        punch_more if user.out?
      end
      div(class: %(w-full fixed bottom-[39px] z-40 bg-slate-100 opaque-5)) do
        div(class: "max-w-full lg:max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 mb-2") do
          div(class: "border-gray-200 py-2 text-gray-400 justify-items-stretch flex flex-row-reverse gap-2") do
            render PunchClockButtons.new user: user, tab: tab, url: helpers.pos_user_url(api_key: user.access_token), edit: edit
          end
        end
      end unless tab == "profile"
    end
  end


  def punch_more
    div(class: "flex flex-row flex-wrap text-xs hidden", data: { pos_user_target: "evenMoreOptions" }) do
      extra_button "bg-red-500", helpers.t(".child_sick"), :child_sick
      extra_button "bg-red-500", helpers.t(".nursing_sick"), :nursing_sick
      extra_button "bg-red-500", helpers.t(".p56_sick"), :p56_sick
      extra_button "bg-red-500", helpers.t(".lost_work_sick"), :lost_work_sick
      extra_button "bg-blue-500", helpers.t(".rr_free"), :rr_free
      extra_button "bg-blue-500", helpers.t(".senior_free"), :senior_free
      extra_button "bg-blue-500", helpers.t(".unpaid_free"), :unpaid_free
      extra_button "bg-blue-500", helpers.t(".maternity_free"), :maternity_free
      extra_button "bg-blue-500", helpers.t(".leave_free"), :leave_free
    end
    div(class: "flex flex-row flex-wrap text-xs hidden", data: { pos_user_target: "moreOptions" }) do
      button_tag(helpers.t(".even_more_options"), type: "button", data: { action: "click->pos-user#toggleEvenMoreOptions" }, class: "bg-slate-200 text-white block mx-2 my-2 rounded-md px-3 py-2 font-medium")
      extra_button "bg-blue-500", helpers.t(".free"), :free
      extra_button "bg-red-500", helpers.t(".iam_sick"), :iam_sick
    end
  end

  def extra_button(color, text, state)
    div(class: "justify-self-end") do
      button_tag(text, type: "submit", form: "form_#{ state }", class: "#{ color } text-white block rounded-md mx-2 my-2 px-3 py-2 text-sm font-medium")
      form_with url: helpers.pos_user_url(api_key: user.access_token), id: "form_#{ state }", method: :post do
        hidden_field(:user, :api_key, value: user.access_token)
        hidden_field :user, :state, value: state
        hidden_field :user, :id, value: user.id
        hidden_field :duration, value: 1.day
      end
    end
  end
end
