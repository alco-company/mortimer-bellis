class Events::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "event-form" }) do
      # row field(:name).input()
      # row field(:files).file(class: "mort-form-file", multiple: true)
      row field(:calendar_id).hidden
      row field(:tenant_id).hidden
      render EventComponent.new resource: resource
    end
  end
end
