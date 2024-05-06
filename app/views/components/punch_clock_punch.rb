class PunchClockPunch < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField
  include Phlex::Rails::Helpers::ButtonTag

  attr_accessor :resource, :employee, :pane

  def initialize(resource:, employee: nil, tab: "today")
    @resource = resource
    @employee = employee || false
    @pane = tab
  end

  def view_template
    div(class: "h-full w-full") do
      div(class: "sm:p-4 ") do
        punch_buttons
        todays_minutes

        h4(class: "m-4 text-gray-700 text-xl") { helpers.t(".todays_punches") }
        ul(class: "m-4") do
          employee.todays_punches.each do |punch|
            li(
              id: (helpers.dom_id punch),
              class: "flex items-center justify-between gap-x-6 py-5"
            ) do
              div(class: "min-w-0 w-full columns-2") do
                span { helpers.render_datetime_column(field: punch.punched_at, css: "") }
                span { helpers.render_text_column(field: punch.state, css: "text-right") }
              end
              div(class: "flex flex-none items-center gap-x-4") do
                helpers.render_contextmenu resource: punch, turbo_frame: helpers.dom_id(punch), alter: false
              end
            end
          end
        end

        # div( class: "flex items-center justify-between w-full p-5 font-medium rtl:text-right text-gray-500 border border-gray-200 sm:rounded-b-xl focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 dark:text-gray-400 gap-3") do
        #   case pane
        #     when 'profile'; show_profile
        #     when 'today'; show_today
        #     when 'payroll'; show_payroll
        #   end
        # end
      end
    end
  end

  def punch_buttons
    div(class: "flex items-center justify-center w-full p-5 font-medium rtl:text-right text-gray-500 gap-3") do
      punch_in
      punch_break
      punch_out
    end
  end

  def todays_minutes
    div(class: "flex items-center justify-center w-full p-5 font-medium rtl:text-right text-gray-500 gap-3") do
      counters = employee.minutes_today_up_to_now
      say "counters: #{counters}"
      render Stats.new title: "Arbejdstid, mm", stats: [
        { title: "Arbejdstid", value: helpers.display_hours_minutes(counters[:work]) },
        { title: "Pauser", value: helpers.display_hours_minutes(counters[:break]) }
    ]
    end if employee
  end

  def punch_in
    return if employee.state == "IN"
    button_tag helpers.t(".in"), type: "submit", form: "inform", class: "bg-green-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
    form_with url: pos_punch_clock_url, id: "inform", method: :post do
      hidden_field :punch_clock, :api_key, value: resource.access_token
      hidden_field :employee, :state, value: "IN"
      hidden_field :employee, :id, value: employee.id
    end
  end

  def punch_break
    return unless employee.state == "IN"
    button_tag helpers.t(".break"), type: "submit", form: "breakform", class: "bg-yellow-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
    form_with url: pos_punch_clock_url, id: "breakform", method: :post do
      hidden_field :punch_clock, :api_key, value: resource.access_token
      hidden_field :employee, :state, value: "BREAK"
      hidden_field :employee, :id, value: employee.id
    end
  end

  def punch_out
    return unless employee.state == "IN"
    button_tag helpers.t(".out"), type: "submit", form: "outform", class: "bg-red-500 text-white block rounded-md px-3 py-2 text-xl font-medium"
    form_with url: pos_punch_clock_url, id: "outform", method: :post do
      hidden_field :punch_clock, :api_key, value: resource.access_token
      hidden_field :employee, :state, value: "OUT"
      hidden_field :employee, :id, value: employee.id
    end
  end

  def active_tab(t)
    t == pane ? "bg-gray-700" : "bg-gray-300"
  end

  def show_profile
    div(class: "w-full") do
      h2(class: "text-gray-700 text-xl") { helpers.t(".profile") }
      div(class: "text-gray-700 text-xl") { "coming soon - this will be for the employee to add an avatar/photo and their name/moniker" }
    end
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

  def show_today
    helpers.render_today_header
  end
end
