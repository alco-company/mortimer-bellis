# app/views/editor/form.rb
class Editors::Html::Preview < ApplicationComponent
  attr_reader :resource
  # This component is used to render a live HTML preview of the resource.
  # It expects a resource object that responds_to :to_html
  def initialize(resource: nil)
    @resource = resource
    super()
  end

  # This method will render the HTML structure editor UI.
  # You can add drag/drop blocks or fields here.
  def view_template
    resource ?
      preview_resource :
      div do
        p(class: "text-gray-500") { "Live HTML preview will go here." }
        div(
            id: "preview_pane",
            class: "mt-4 p-4 shadow-md rounded-sm bg-white",
            data: { editor_target: "preview" }
        )
        # Add drag/drop blocks or fields here
      end
  end

  def preview_resource
    div(
      id: "preview_pane",
      class: "mt-4 p-4 shadow-md rounded-sm bg-white",
      data: { editor_target: "preview" }
    ) do
      render_resource_html
    end
  end

  def render_resource_html
    html = resource.to_html # blocks.map { |block| Editor::BlockHtmlSerializer.new(block).to_html }.join
    unsafe_raw(html)
  end
end
