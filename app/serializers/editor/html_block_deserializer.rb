# app/serializers/editor/html_block_deserializer.rb
module Editor
  class HtmlBlockDeserializer
    attr_accessor :html, :document, :position

    def initialize(html:, document:)
      @html = html
      @document = document
      document.blocks.destroy_all
      @position = 0
    end

    def to_block
      # Parse the HTML and extract block attributes
      fragment = Nokogiri::HTML::DocumentFragment.parse(@html)
      blocks = fragment.children.map { |node| build_block_from_node(node, nil) }.compact
      blocks
    end

    def build_block_from_node(node, parent)
      return nil unless node.is_a?(Nokogiri::XML::Element)

      block_type = node.name
      data = node.attributes.transform_values(&:value)
      text_content = node.text.strip

      # Create a new block
      block = Editor::Block.new(
        type: block_type,
        data: { "text" => text_content }.merge(data),
        parent: parent,
        position: @position += 1
      )

      # Save the block to the document
      @document.blocks << block

      # Process children recursively
      node.children.each do |child_node|
        child_block = build_block_from_node(child_node, block)
        # does this add a block?
        block.children << child_block if child_block
      end

      block
    rescue StandardError => e
      Rails.logger.error("Error building block from node: #{e.message}")
      nil
    end
  end
end
