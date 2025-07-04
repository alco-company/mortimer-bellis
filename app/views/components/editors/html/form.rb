# app/views/editor/form.rb
class Editors::Html::Form < ApplicationComponent
  def initialize
    super
  end

  # This method will render the HTML structure editor UI.
  # You can add drag/drop blocks or fields here.
  def view_template
    div do
      p(class: "text-gray-500") { "This will be your HTML structure editor UI." }
      textarea(
          id: "editor-input",
          class: "w-full h-64 border p-2 font-mono",
          data: { editor_target: "input", action: "input->editor#update" }
        )

      # Add drag/drop blocks or fields here
    end
  end
end
