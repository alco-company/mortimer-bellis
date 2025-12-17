class Tasks::ModalForm < ApplicationForm
  include Phlex::Rails::Helpers::ButtonTag

  def view_template(&)
    row field(:title).input().focus
    if Current.get_user.can?(:delegate_time_materials, resource: @resource)
      div(class: "my-1 grid grid-cols-4 gap-x-1 md:gap-x-4 gap-y-1 ") do
        div(class: "my-0 col-span-4 xs:col-span-2") do
          row field(:due_at).date(class: "mort-form-date"), "mort-field my-0"
        end
        div(class: "my-0 col-span-4 xs:col-span-2") do
          row field(:tasked_for_id).select(User.user_list, data: { action: "change->task#userChanged" }, class: "mort-form-select my-0"), "mort-field my-0"
          row field(:tasked_for_type).hidden(value: "User")
        end
      end
    else
      div(class: "mt-1") do
        row field(:due_at).date(class: "mort-form-date")
      end
    end
    row field(:customer_id).lookup(class: "mort-form-text #{field_id_error(resource.customer_name, resource.customer_id, resource.is_invoice?)}",
      data: {
        url: "/customers/lookup",
        div_id: "task_customer_id",
        lookup_target: "input",
        action: "keydown->lookup#keyDown blur->task#customerChange"
      },
      display_value: @resource.customer_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
    row field(:project_id).lookup(class: "mort-form-text #{field_id_error(resource.project_name, resource.project_id)}",
      data: {
        url: "/projects/lookup",
        div_id: "task_project_id",
        lookup_target: "input",
        lookup_association: "customer_id",
        lookup_association_div_id: "task_customer_id",
        action: "keydown->lookup#keyDown blur->task#projectChange"
      },
      display_value: @resource.project_name), "mort-field my-1" # Customer.all.select(:id, :name).take(9)
    row field(:description).textarea(class: "mort-form-text"), "mort-field my-0"

    input(name: "modal_form", type: :hidden, value: "new_task")
    input(name: "resource_class", type: "hidden", value: "task")
    input(name: "step", type: "hidden", value: "step")
    input(name: "id", type: "hidden", value: resource&.id)
    input(name: "url", type: "hidden", value: resource.persisted? ? resource_url(resource) : resources_url)

    div class: "mt-5 sm:mt-4 flex justify-between flex-row-reverse" do
      button_tag t("task.save"), data: { modal_target: "submitForm", action: "modal#submitForm" }, class: "mort-btn-alert flex-none"
      button_tag t(:cancel), form: "dialog_form", formmethod: :dialog,  data: { action: "click->modal#close" }, class: "mort-btn-cancel flex-none"
    end
  end

  def field_id_error(value, dependant, allowed = true)
    if !value.blank? and dependant.blank? and allowed
      "border-1 border-red-500"
    end
  end
end
