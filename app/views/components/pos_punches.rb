class PosPunches < ApplicationComponent
  def initialize(punches:)
    @punches = punches
  end

  def view_template
    current_date = nil
    employee = @punches.first.employee
    @punches.each do |punch|
      if punch.punched_at.to_date != current_date
        current_date = punch.punched_at&.to_date
        li(id: "payroll_#{(helpers.dom_id punch)}", class: "flex items-center justify-between gap-x-6 py-5") do
          div(class: "min-w-0 w-full columns-2") do
            span { helpers.render_date_column(value: punch.punched_at, css: "font-medium") }
          end
          div(class: "flex flex-none items-center gap-x-4") do
            render(PosContextmenu.new(resource: punch, list: true, turbo_frame: helpers.dom_id(punch), alter: false))
          end
        end
      end
      li(
        id: (helpers.dom_id punch),
        class: "flex items-center justify-between gap-x-6 py-5"
      ) do
        div(class: "min-w-0 w-full columns-2") do
          span { helpers.render_text_column(value: helpers.tell_state(punch), css: "text-right") }
          span { helpers.render_time_column(value: punch.punched_at, css: "") }
        end
        div(class: "flex flex-none items-center gap-x-4") do
          render PosContextmenu.new resource: punch, turbo_frame: helpers.dom_id(punch), alter: false, links: [ pos_employee_edit_url(api_key: employee.access_token, id: punch.id), pos_employee_delete_url(api_key: employee.access_token, id: punch.id) ]
        end
      end
    end
  end
end
