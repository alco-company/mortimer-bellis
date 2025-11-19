class Editor::Document < ApplicationRecord
  self.table_name = "editor_documents"

  # NOTE: BackupTenantJob and RestoreTenantJob tests do not currently verify
  # restoration of editor documents and their nested block structure. Backup/restore
  # should work but the hierarchical block relationships are untested.

  belongs_to :tenant, class_name: "Tenant", optional: true
  has_many :blocks, -> { where(parent_id: nil).order(:position) }, class_name: "Editor::Block", dependent: :destroy
  # has_many :children, -> { order(:position) }, class_name: "Editor::Block", foreign_key: :parent_id, dependent: :destroy

  accepts_nested_attributes_for :blocks, allow_destroy: true
  # accepts_nested_attributes_for :children, allow_destroy: true

  validates :title, presence: true

  def to_html
    html = blocks.map { |block| Editor::BlockHtmlSerializer.new(block).to_html }.join
    Editor::LiquidRenderer.new(resource: self, html: html).interpolate
  end

  def to_json
    {
      id: id,
      name: name,
      blocks: blocks.map(&:to_json)
    }.to_json
  end

  def to_xml
    {
      id: id,
      name: name,
      blocks: blocks.map(&:to_xml)
    }.to_xml
  end

  def to_text
    blocks.map(&:to_text).join("\n")
  end

  def to_markdown
    blocks.map(&:to_markdown).join("\n")
  end

  def to_pdf
    blocks.map(&:to_pdf).join("\n")
  end

  def to_csv
    blocks.map(&:to_csv).join("\n")
  end

  def to_yaml
    blocks.map(&:to_yaml).join("\n")
  end

  def to_docx
    blocks.map(&:to_docx).join("\n")
  end
end
