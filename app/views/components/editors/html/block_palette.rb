# app/views/editor/form.rb
class Editors::Html::BlockPalette < ApplicationComponent
  def initialize
    super
  end

  # This method will render the HTML structure editor UI.
  # You can add drag/drop blocks or fields here.
  def view_template
    div(class: "flex flex-col space-y-1") do
      block_button("Container", "div")
      block_button("Paragraph", "p")
      block_button("Heading", "h1")
      block_button("Image", "image")
    end
  end

  def block_button(label, type)
    div(
      class: "cursor-move bg-white border rounded p-2 text-center text-sm hover:bg-gray-200",
      draggable: "true",
      data: {
        block_type: type,
        origin: "palette",
        action: "dragstart->editor-dnd#dragStart",
        editor_dnd_block_type_param: type
      },
    ) { label }
  end
end
