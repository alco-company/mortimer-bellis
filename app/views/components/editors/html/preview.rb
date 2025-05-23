# app/views/editor/form.rb
class Editors::Html::Preview < ApplicationComponent
  def initialize
    super
  end

  # This method will render the HTML structure editor UI.
  # You can add drag/drop blocks or fields here.
  def view_template
    div do
      p(class: "text-gray-500") { "Live HTML preview will go here." }
      div(
          id: "preview-pane",
          class: "mt-4 p-4 shadow-md rounded-sm bg-white",
          data: { editor_target: "preview" }
      )
      # Add drag/drop blocks or fields here
    end
  end
end
