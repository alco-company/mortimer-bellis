class TimeMaterials::Form < ApplicationForm
  def view_template(&)
    url = @resource.id.nil? ? time_materials_url : time_material_url(@resource)
    render TimeMaterialForm.new time_material: @resource, url: url
  end
end
