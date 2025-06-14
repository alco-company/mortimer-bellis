# frozen_string_literal: true

class Editors::Html::UI < ApplicationComponent
  def initialize(document: nil)
    @document = document
    # super
  end

  # This method will render the HTML structure editor UI.
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

      # Preview pane wrapper with controls
      div(data: { controller: "preview" }, class: "flex-1 flex flex-col overflow-auto p-4 bg-gray-50") do
        # Device toggle
        div(class: "mb-4 space-x-2") do
          button(
            class: "px-3 py-1  cursor-pointer rounded border bg-white hover:bg-gray-100",
            data: { action: "click->preview#setSize", preview_size_param: "375" }
          ) { "Mobile" }
          button(
            class: "px-3 py-1 cursor-pointer rounded border bg-white hover:bg-gray-100",
            data: { action: "click->preview#setSize", preview_size_param: "768" }
          ) { "Tablet" }
          button(
            class: "px-3 py-1 cursor-pointer rounded border bg-white hover:bg-gray-100",
            data: { action: "click->preview#setSize", preview_size_param: "full" }
          ) { "Desktop" }
          button(
            class: "px-3 py-1 rounded border bg-gray-100 hover:bg-gray-100",
            data: { action: "click->preview#setSize", preview_size_param: "pdf" }
          ) { "PDF" }
        end

        # Preview container (width adjusted by JS)
        div(id: "preview-container", class: "mx-auto border bg-white p-4 shadow", data: { preview_target: "container" }) do
          render Editors::Html::Preview.new document: @document
        end
      end
    end
  end
end
