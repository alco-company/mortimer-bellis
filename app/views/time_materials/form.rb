class TimeMaterials::Form < ApplicationForm
  def view_template(&)
    row field(:date).date(class: "mort-form-text")
    div do
      div(class: "") do
        # error_messages


        div(class: "border-b border-gray-200") do
          nav(class: "-mb-px flex space-x-8", aria_label: "Tabs") do
            # time_tab
            # material_tab
          end
        end
      end
    end

    row field(:customer_id).lookup(class: "mort-form-text",
      lookup_path: "/customers/lookup",
      display_value: @resource.customer_name).focus # Customer.all.select(:id, :name).take(9)

    url = @resource.id.nil? ? time_materials_url : time_material_url(@resource)
    render TimeMaterialForm.new time_material: @resource, url: url
  end
end
