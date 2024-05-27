class PunchClockPunch < PunchClockBase
  attr_accessor :resource, :employee, :pane, :tab, :punch_clock

  def initialize(resource:, employee: nil, tab: "today")
    @resource = @punch_clock = resource
    @employee = employee || false
    @tab = tab
  end

  def view_template
    div(class: "h-full w-full") do
      div(class: "sm:p-4 ") do
        punch_buttons
        todays_minutes
        div(class: "grid grid-cols-2 gap-5") do
          div() do
            list_punches ".todays_punches", employee.todays_punches
          end
          div(class: "h-full ") do
            list_punches ".payroll_punches", employee.punches.by_payroll_period(employee.punches_settled_at).order(punched_at: :desc), false, true, "payroll"
          end
        end
      end
    end
  end

  def punch_buttons
    div(class: "flex items-center justify-center w-full p-5 font-medium rtl:text-right text-gray-500 gap-3") do
      render PunchClockButtons.new(punch_clock: resource, employee: employee, tab: tab, url:  pos_punch_clock_url)
    end
  end

  # def punch_in
  #   return if employee.in?
  #   button_tag helpers.t(".in"), type: "submit", form: "inform", class: "bg-green-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
  #   form_with url: pos_punch_clock_url, id: "inform", method: :post do
  #     hidden_field :punch_clock, :api_key, value: resource.access_token
  #     hidden_field :employee, :state, value: :in
  #     hidden_field :employee, :id, value: employee.id
  #   end
  # end

  # def punch_break
  #   return unless employee.in?
  #   button_tag helpers.t(".break"), type: "submit", form: "breakform", class: "bg-yellow-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
  #   form_with url: pos_punch_clock_url, id: "breakform", method: :post do
  #     hidden_field :punch_clock, :api_key, value: resource.access_token
  #     hidden_field :employee, :state, value: :break
  #     hidden_field :employee, :id, value: employee.id
  #   end
  # end

  # def punch_out
  #   return unless employee.in?
  #   button_tag helpers.t(".out"), type: "submit", form: "outform", class: "bg-red-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
  #   form_with url: pos_punch_clock_url, id: "outform", method: :post do
  #     hidden_field :punch_clock, :api_key, value: resource.access_token
  #     hidden_field :employee, :state, value: :out
  #     hidden_field :employee, :id, value: employee.id
  #   end
  # end
end
