class WorkScheduleTemplateList < ApplicationComponent
  include Phlex::Rails::Helpers::LinkTo

  def initialize(&block)
  end

  def view_template(&block)
    div(class: "grid gap-x-4 grid-cols-1 xl:grid-cols-2") do
      div(data: { toggle_button_target: "newTemplate" }, class: "hidden my-4 w-full grid grid-cols-2") do
        p(class: "col-span-2 my-2 ") { t("calendar.template.instructions_1") }
        p(class: "col-span-2 my-2 ") { t("calendar.template.instructions_2") }
        p(class: "col-span-2 my-2 ") { t("calendar.template.instructions_3") }
        label(class: "my-2 font-bold mx-2 ") { t("calendar.template.event_name") }
        input(type: "text", name: "event[name]", class: "mort-form-text my-2")
        render SelectComponent.new(resource: Event.new,
          field: :color,
          field_class: "my-2 grid grid-cols-2 col-span-2",
          label_class: "mx-2 col-span-1",
          value_class: "mt-2 ",
          collection: Team.colors,
          show_label: true,
          prompt: t(".select_team_color"),
          editable: true)
        button(type: "submit", class: "col-span-2 place-self-end mort-btn-primary") { "Gem" }
      end
      div(data: { toggle_button_target: "newTemplate" }, class: "hidden my-4 w-full") do
        work_schedule_templates = [ "template1", "template2", "template3" ]
        ul(role: "list", class: "divide-y divide-gray-100") do
          work_schedule_templates.each do |template|
            render WorkScheduleTemplate.new(template: template)
          end
        end
      end
    end
  end
end
