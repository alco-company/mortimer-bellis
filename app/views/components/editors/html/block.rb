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
      id: dom_id(block),
      data: { id: block.id, action: "drop->editor-dnd#drop" },
      class: "border rounded mb-2 p-2 bg-white cursor-move"
    ) do
      draw_block_content
    end
  end

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
