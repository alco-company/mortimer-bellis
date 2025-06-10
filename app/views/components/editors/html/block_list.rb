# app/views/editor/form.rb
class Editors::Html::BlockList < ApplicationComponent
  attr_accessor :document

  def initialize(document:)
    @document = document
    super()
  end

  # This method will render the HTML structure editor UI.
  # You can add drag/drop blocks or fields here.
  def view_template
    div(
      id: "block_list",
      class: "shadow-md p-2 w-full",
      data: {
        drop_position: "after",
        editor_dnd_target: "dropzone",
        sort_target: "sortedcontainer"
      }
    ) do
      div(
        class: "w-2 h-2 bg-transparent hover:bg-blue-200 transition-colors",
        data: {
          drop_position: "after",
          action: "dragover->editor-dnd#dragOver drop->editor-dnd#drop"
        }
      )
      @document.blocks.order(:position).each do |block|
        render Editors::Html::Block.new(block: block)
      end
    end
  end
end
