module PhlexHelpers
  #
  # will allow tests like:
  # output = raw_render Components::Hello.new
  # assert_equal "<h1>Hello</h1>", output
  #
  def raw_render(component)
    component.call
  end

  def render(...)
    view_context.render(...)
  end

  def view_context
    controller.view_context
  end

  def controller
    @controller ||= ActionView::TestCase::TestController.new
  end

  def render_fragment(...)
    html = render(...)
    Nokogiri::HTML5.fragment(html)
  end

  def render_document(...)
    html = render(...)
    Nokogiri::HTML5(html)
  end
end
