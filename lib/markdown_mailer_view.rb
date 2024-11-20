require "redcarpet/render_strip"
module MarkdownMailerView
  # include ApplicationMailerView
  include Phlex::Rails::Helpers::StripTags

  def render_plaintext
    strip_tags(Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(markdown_template))
  end

  def markdown(text)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, {}).render(text)
  end

  def view_template
    div(class: "prose prose-stone mx-auto my-10 px-4") do
      # header

      markdown(markdown_template).html_safe

      # footer
    end
  end
end
