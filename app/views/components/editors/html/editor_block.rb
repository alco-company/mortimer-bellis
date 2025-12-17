# app/views/editor/form.rb
class Editors::Html::EditorBlock < ApplicationComponent
  attr_accessor :document

  # mortimer_scoped - override on tables with other tenant scoping association
  scope :mortimer_scoped, ->(ids) { unscoped.where("0=#{ids}") } # effectively returns no records

  validates :name, presence: true

  def self.scoped_for_tenant(ids = 1)
    mortimer_scoped(ids)
  end

  # This component is used to render the HTML structure editor UI.
  # It allows users to add, drag, and drop blocks or fields to create a structured HTML document.
  #
  def initialize(document: nil, hidden: false)
    @document = document
    @hidden = hidden ? "hidden" : ""
    super()
  end

  # This method will render the HTML structure editor UI.
  # You can add drag/drop blocks or fields here.
  def view_template
    div(
      id: "editor_blocks",
      class: "#{@hidden} flex space-x-1",
      data: {
        controller: "editor-dnd",
        # block_id: "",
        # block_type: "",
        # action: "dragover->editor-dnd#dragOver drop->editor-dnd#drop",
        editor_dnd_document_id_value: document&.id,
        tabs_target: "tabPanel"
      }) do
      render Editors::Html::BlockPalette.new

      # Wrap sortable block list
      render Editors::Html::BlockList.new(document: document)
    end
  end
end
