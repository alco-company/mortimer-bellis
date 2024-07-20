class Events::Form < ApplicationForm
  def view_template(&)
    div(data: { controller: "event-form" }) do
      # row field(:name).input(class: "mort-form-text")
      # row field(:files).file(class: "mort-form-file", multiple: true)
      row field(:calendar_id).hidden
      row field(:account_id).hidden
      render EventComponent.new
    end
  end
end
