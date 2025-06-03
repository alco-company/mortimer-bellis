# app/views/editor/form.rb
class Editors::Html::Form < ApplicationComponent
  attr_accessor :document

  def initialize (document: nil)
    @document = document
    super()
  end

  # This method will render the HTML structure editor UI.
  # You can add drag/drop blocks or fields here.
  def view_template
    div(id: "editor-pane") do
      p(class: "text-gray-500") { "This will be your HTML structure editor UI." }
      textarea(
          id: "editor-input",
          class: "w-full h-64 border p-2 font-mono",
          data: { editor_dnd_target: "dropzone", document_id: document.id, editor_target: "input", action: "input->editor#update" }
        ) do
          plain document&.to_html
        end

      # Add drag/drop blocks or fields here
    end
  end
end
