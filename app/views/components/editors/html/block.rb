# app/views/editor/form.rb
class Editors::Html::Block < ApplicationComponent
  include Phlex::Rails::Helpers::DOMID

  attr_accessor :block

  def initialize (block: nil)
    @block = block
    super()
  end

  # This method will render the HTML structure editor UI.
  # You can add drag/drop blocks or fields here.
  def view_template
    div(
      class: "flex relative"
    ) do
      drop_before
      content
      drop_after
    end
  end

  def drop_before
    # Top drop zone
    div(
      class: "w-2 bg-transparent bg-green-500 hover:bg-green-500 transition-colors",
      data: {
        action: "dragover->editor-dnd#dragOver drop->editor-dnd#drop",
        drop_position: "before",
        block_id: block.id
      }
    )
  end

  def content
    div(
      id: dom_id(block),
      draggable: "true",
      data: {
        action: "dragstart->editor-dnd#dragStart drop->editor-dnd#drop",
        block_id: block.id,
        block_type: block.type,
        origin: "canvas"
      },
      class: "border rounded mb-2 p-2 bg-white cursor-move"
    ) do
      draw_block_content
    end
  end

  def drop_after
    # Bottom drop zone
    div(
      class: "w-2 bg-transparent bg-red-500 hover:bg-red-200 transition-colors",
      data: {
        action: "dragover->editor-dnd#dragOver drop->editor-dnd#drop",
        drop_position: "after",
        block_id: block.id
      }
    )
  end

  # This method draws the content of the block.
  def draw_block_content
    if block.children.any?
      div(class: "mt-2 border border-gray-300") do
        block.children.order(:position).each do |child|
          render Editors::Html::Block.new(block: child)
        end
      end
    else
      span(class: "border border-gray-300") { block.text }
    end
  end
end
