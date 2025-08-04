# app/serializers/editor/block_html_serializer.rb
module Editor
  class BlockHtmlSerializer
    def initialize(block)
      @block = block
    end

    def to_html
      children_html = render_children.presence
      data = @block.data_parsed

      case @block.type
      # when "div", "section", "article", "aside", "nav", "header", "footer", "main", "span"
      #   content_tag(@block.type, data["text"] + (children_html || ""), data.except("text"))
      # when "p", "h1", "h2", "h3", "h4", "h5", "h6"
      #   content_tag(@block.type, data["text"] + (children_html || ""), data.except("text"))
      when "image"
        tag("img", data.slice("src", "alt"))
      else
        content_tag(@block.type, data["text"] + (children_html || ""), data.except("text"))
        # children_html.to_s
      end
    end

    private

    def render_children
      @block.children.order(:position).map do |child|
        self.class.new(child).to_html
      end.join
    end

    def content_tag(tag, content = nil, attrs = {})
      data = @block.data_parsed
      attributes = data.except("text")
      attributes = attributes.merge(attrs).map { |k, v| %(#{k}="#{v}") }.compact
      attributes = attributes.empty? ? "" : " %s" % attributes.join(" ")
      html = if content
        "<#{tag}#{attributes}>#{content}</#{tag}>"
      else
        "<#{tag}#{attributes.strip}/>"
      end
      html
    end

    def tag(name, attrs = {})
      "<#{name} #{attrs.map { |k, v| %(#{k}="#{v}") }.join(" ")} />"
    end
  end
end
