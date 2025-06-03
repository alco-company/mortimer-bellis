# frozen_string_literal: true

class Editors::Html::UI < ApplicationComponent
  def initialize(document: nil)
    @document = document
    super()
  end

  # This method will render the HTML structure editor UI.
  def view_template
    div(class: "flex h-screen overflow-hidden", data: { controller: "split editor" }) do
      # Editor pane
      div(id: "editor-container", data: { controller: "editor-dnd", editor_dnd_document_id_value: @document&.id }, class: "overflow-auto p-4 border-r", style: "width: 50%; min-width: 300px;") do
        div(
          class: "p-4 h-[70%] overflow-auto",
          data: { editor_dnd_target: "dropzone" }
        ) do
          h2(class: "text-xl font-bold mb-4") { "Editor" }
          render Editors::Html::Form.new document: @document

          # Wrap sortable block list
          div(id: "editor_blocks", data: { controller: "sort", sort_target: "container" }) do
            @document.blocks.order(:position).each do |block|
              render Editors::Html::Block.new(block: block)
            end
          end
        end

        # Block palette area
        div(class: "p-4 border-t h-[30%] overflow-y-auto bg-gray-100") do
          h3(class: "text-sm font-semibold mb-2 text-gray-600") { "Blocks" }
          render Editors::Html::BlockPalette.new
        end
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
