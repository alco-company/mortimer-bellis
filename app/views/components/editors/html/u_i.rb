# frozen_string_literal: true

class Editors::Html::UI < ApplicationComponent
  def view_template
    div(class: "flex h-screen overflow-hidden", data: { controller: "split editor" }) do
      # Editor pane
      div(id: "editor-pane", class: "overflow-auto p-4 border-r", style: "width: 50%; min-width: 300px;") do
        h2(class: "text-xl font-bold mb-4") { "Editor" }
        render Editors::Html::Form.new
      end

      # Divider (drag handle)
      div(
        class: "w-2 cursor-col-resize bg-gray-200 hover:bg-gray-300 transition-all",
        data: { action: "mousedown->split#startResize" }
      )

      # Preview pane
      div(id: "preview-pane", class: "flex-1 overflow-auto p-4 bg-gray-50") do
        h2(class: "text-xl font-bold mb-4") { "Preview" }
        render Editors::Html::Preview.new
      end
    end
  end
end
