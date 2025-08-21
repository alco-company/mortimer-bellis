class PunchClockButtons < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTag
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField

  attr_accessor :user, :tab, :edit

  # PunchClockButtons.new user: employee, tab: tab, url: pos_employee_url(api_key: user.access_token)
  def initialize(punch_clock: nil, user: nil, url: nil, tab: nil, edit: false)
    @punch_clock = punch_clock
    @user = user || false
    @url = url
    @tab = tab || false
    @edit = edit
  end

  def view_template(&block)
    if user.archived?
      t("user.archived")
    else
      if tab == "payroll"
        punch_add
      else
        punch_in
        punch_break
        punch_out
        more_button
      end
    end
  end

  def more_button
    return unless user.out?
    div(class: "justify-self-end") do
      button_tag(t(".more_options"), type: "button", data: { action: "click->pos-employee#toggleMoreOptions" }, class: "bg-slate-200 text-white block rounded-md px-3 py-2 text-xl font-medium mr-2")
    end
  end

  def punch_in
    return if user.in?
    div(class: "justify-self-end") do
      button_tag(t(".in"), type: "submit", form: "inform", class: "bg-green-500 text-white block rounded-md px-3 py-2 text-xl font-medium")
      form_with url: @url, id: "inform", method: :post do
        @punch_clock ?
          hidden_field(:punch_clock, :api_key, value: @punch_clock.access_token) :
          hidden_field(:user, :api_key, value: user.access_token)
        hidden_field :user, :state, value: 1
        hidden_field :user, :id, value: user.id
      end
    end
  end

  def punch_break
    return unless user.in?
    div(class: "justify-self-end") do
      button_tag t(".break"), type: "submit", form: "breakform", class: "bg-yellow-500 text-white block mx-2 justify-self-end rounded-md px-3 py-2 text-xl font-medium"
      form_with url: @url, id: "breakform", method: :post do
        @punch_clock ?
          hidden_field(:punch_clock, :api_key, value: @punch_clock.access_token) :
          hidden_field(:user, :api_key, value: user.access_token)
        hidden_field :user, :state, value: 2
        hidden_field :user, :id, value: user.id
      end
    end
  end

  def punch_out
    return unless user.in?
    div(class: "justify-self-end") do
      button_tag t(".out"), type: "submit", form: "outform", class: "bg-red-500 text-white block mx-2 rounded-md px-3 py-2 text-xl font-medium"
      form_with url: @url, id: "outform", method: :post do
        @punch_clock ?
          hidden_field(:punch_clock, :api_key, value: @punch_clock.access_token) :
          hidden_field(:user, :api_key, value: user.access_token)
        hidden_field :user, :state, value: 0
        hidden_field :user, :id, value: user.id
      end
    end
  end

  def punch_add
    div(class: "flex justify-self-end") do
      edit ?
        cancel_and_save :
        link_to(t(".add"), pos_employee_url(api_key: user.access_token, tab: "payroll", edit: true), class: "mort-btn-primary")
    end
  end

  def cancel_and_save
    link_to(t(".cancel"), pos_employee_url(api_key: user.access_token, tab: "payroll"), class: "mort-btn-cancel mr-4")
    button_tag(t(".save"), type: "submit", form: "manualpunch", class: "mort-btn-save")
  end
end
