class Editor::LiquidRenderer
  attr_accessor :resource, :html

  def initialize(resource:, html:)
    @resource = resource
    @html = html
  end

  # will substitute {{ content }} with the actual HTML content
  def interpolate
    m = html.scan(/\{\{(.*?)\}\}/)
    return html if m.flatten.empty?
    m.flatten.each do |match|
      html.gsub!(/\{\{(#{match})\}\}/, interpolate_element(match))
    end
    html
  end

  #
  # interpolate_element takes a match from the interpolation regex
  # and returns the corresponding value from the resource.
  #
  def interpolate_element(match)
    case match.strip
    when "tenant.name"; resource.tenant.name
    else match
    end
  end

  class << self
    def render(template, context: {})
      Liquid::Template.parse(template).render(context)
    rescue Liquid::SyntaxError => e
      Rails.logger.error("Liquid syntax error: #{e.message}")
      "<p>Error rendering template: #{e.message}</p>"
    end

    def render_resource(resource)
      resource.to_html
    end
  end
end
