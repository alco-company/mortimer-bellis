class PunchClockButtons < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTag
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField

  attr_accessor :employee, :tab

  def initialize(employee: nil, tab: nil)
    @employee = employee || false
    @tab = tab || false
  end

  def view_template(&block)
    div(
      class:
        %(w-full fixed bottom-[40px] z-40 bg-slate-100 opaque-5)
    ) do
      div(
        class:
          "max-w-full lg:max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 mb-2"
      ) do
        div(
          class:
            "border-gray-200 py-2 text-gray-400 justify-items-stretch flex flex-row-reverse gap-2"
        ) do
          punch_in
          punch_break
          punch_out
          punch_add if tab == "payroll"
        end
      end
    end
  end

  def punch_in
    return if employee.in?
    div(class: "justify-self-end") do
      button_tag helpers.t(".in"), type: "submit", form: "inform", class: "bg-green-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
      form_with url: helpers.pos_employee_url(api_key: employee.access_token), id: "inform", method: :post do
        hidden_field :employee, :api_key, value: employee.access_token
        hidden_field :employee, :state, value: :in
        hidden_field :employee, :id, value: employee.id
      end
    end
  end

  def punch_break
    return unless employee.in?
    div(class: "justify-self-end") do
      button_tag helpers.t(".break"), type: "submit", form: "breakform", class: "bg-yellow-500 text-white block mx-2 justify-self-end rounded-md px-3 py-2 text-xl font-medium"
      form_with url: helpers.pos_employee_url(api_key: employee.access_token), id: "breakform", method: :post do
        hidden_field :employee, :api_key, value: employee.access_token
        hidden_field :employee, :state, value: :break
        hidden_field :employee, :id, value: employee.id
      end
    end
  end

  def punch_out
    return unless employee.in?
    div(class: "justify-self-end") do
      button_tag helpers.t(".out"), type: "submit", form: "outform", class: "bg-red-500 text-white block mx-2 rounded-md px-3 py-2 text-xl font-medium"
      form_with url: helpers.pos_employee_url(api_key: employee.access_token), id: "outform", method: :post do
        hidden_field :employee, :api_key, value: employee.access_token
        hidden_field :employee, :state, value: :out
        hidden_field :employee, :id, value: employee.id
      end
    end
  end

  def punch_add
    div(class: "justify-self-end") do
      link_to helpers.t(".add"), helpers.pos_employee_url(api_key: employee.access_token, tab: "payroll", edit: true), class: "bg-sky-500 text-white block mx-2 rounded-md px-3 py-2 text-xl font-medium"
    end
  end
end
