class NumberColumn < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  attr_accessor :field

  def initialize(field:, css: nil)
    @field = field
    @class = css || "text-right"
  end

  def view_template
    field.blank? ? 
      div { "&nbsp;".html_safe } :
      div( class: @class ) {field}
  end
end