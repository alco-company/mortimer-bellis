class TimeMaterials::Form < ApplicationForm
  def view_template(&)
    row field(:customer_id).lookup(class: "mort-form-text",
      value: 1401,
      lookup_path: "/customers/lookup",
      display_value: "morsø").focus # Customer.all.select(:id, :name).take(9)

    url = @resource.id.nil? ? time_materials_url : time_material_url(@resource)
    render TimeMaterialForm.new time_material: @resource, url: url
  end
end
