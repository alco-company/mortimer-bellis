# app/views/editor/form.rb
class Editors::Html::Preview < ApplicationComponent
  attr_reader :document
  # This component is used to render a live HTML preview of the document.
  # It expects a document object that contains blocks of HTML.
  # The document should have a `blocks` association that returns an array of blocks.
  # Each block should have a `type` and `data` attributes.
  def initialize(document: nil)
    @document = document
    # super
  end

  # This method will render the HTML structure editor UI.
  # You can add drag/drop blocks or fields here.
  def view_template
    document ?
      preview_document :
      div do
        p(class: "text-gray-500") { "Live HTML preview will go here." }
        div(
            id: "preview-pane",
            class: "mt-4 p-4 shadow-md rounded-sm bg-white",
            data: { editor_target: "preview" }
        )
        # Add drag/drop blocks or fields here
      end
  end

  def preview_document
    html = document.blocks.map { |block| Editor::BlockHtmlSerializer.new(block).to_html }.join
    unsafe_raw(html)
  end
end
