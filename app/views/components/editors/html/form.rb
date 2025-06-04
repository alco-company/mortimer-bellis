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
    div(id: "editor_pane", class: "w-full") do
      form(
        action: "/editor/documents/#{@document.id}",
        data: { turbo_stream: true },
        class: "p-4 bg-white rounded shadow w-full",
        method: "put") do
        textarea(
          id: "editor-input",
          name: "html",
          placeholder: "Enter HTML content here...",
          rows: 10,
          cols: 50,
          class: "w-full h-64 border p-2 font-mono",
          data: { editor_target: "input", action: "input->editor#update" }
        ) do
          plain document&.to_html
        end
        button(class: "mt-2 px-4 py-2 bg-blue-500 text-white rounded") { "Apply HTML" }
      end
      # Add drag/drop blocks or fields here
    end
  end
end
