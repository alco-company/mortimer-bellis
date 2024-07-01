class PunchClockButtons < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTag
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField

  attr_accessor :employee, :tab, :edit

  # PunchClockButtons.new employee: employee, tab: tab, url: helpers.pos_employee_url(api_key: employee.access_token)
  def initialize(punch_clock: nil, employee: nil, url: nil, tab: nil, edit: false)
    @punch_clock = punch_clock
    @employee = employee || false
    @url = url
    @tab = tab || false
    @edit = edit
  end

  def view_template(&block)
    if employee.archived?
      I18n.t("employee.archived")
    else
      if tab == "payroll"
        punch_add
      else
        punch_in
        punch_break
        punch_out
      end
    end
  end

  def punch_in
    return if employee.in?
    div(class: "justify-self-end") do
      button_tag helpers.t(".in"), type: "submit", form: "inform", class: "bg-green-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
      form_with url: @url, id: "inform", method: :post do
        @punch_clock ?
          hidden_field(:punch_clock, :api_key, value: @punch_clock.access_token) :
          hidden_field(:employee, :api_key, value: employee.access_token)
        hidden_field :employee, :state, value: :in
        hidden_field :employee, :id, value: employee.id
      end
    end
  end

  def punch_break
    return unless employee.in?
    div(class: "justify-self-end") do
      button_tag helpers.t(".break"), type: "submit", form: "breakform", class: "bg-yellow-500 text-white block mx-2 justify-self-end rounded-md px-3 py-2 text-xl font-medium"
      form_with url: @url, id: "breakform", method: :post do
        @punch_clock ?
          hidden_field(:punch_clock, :api_key, value: @punch_clock.access_token) :
          hidden_field(:employee, :api_key, value: employee.access_token)
        hidden_field :employee, :state, value: :break
        hidden_field :employee, :id, value: employee.id
      end
    end
  end

  def punch_out
    return unless employee.in?
    div(class: "justify-self-end") do
      button_tag helpers.t(".out"), type: "submit", form: "outform", class: "bg-red-500 text-white block mx-2 rounded-md px-3 py-2 text-xl font-medium"
      form_with url: @url, id: "outform", method: :post do
        @punch_clock ?
          hidden_field(:punch_clock, :api_key, value: @punch_clock.access_token) :
          hidden_field(:employee, :api_key, value: employee.access_token)
        hidden_field :employee, :state, value: :out
        hidden_field :employee, :id, value: employee.id
      end
    end
  end

  def punch_add
    div(class: "flex justify-self-end") do
      edit ?
        cancel_and_save :
        link_to(helpers.t(".add"), helpers.pos_employee_url(api_key: employee.access_token, tab: "payroll", edit: true), class: "mort-btn-primary")
    end
  end

  def cancel_and_save
    link_to(helpers.t(".cancel"), helpers.pos_employee_url(api_key: employee.access_token, tab: "payroll"), class: "mort-btn-cancel mr-4")
    button_tag(helpers.t(".save"), type: "submit", form: "manualpunch", class: "mort-btn-save")
  end
end
