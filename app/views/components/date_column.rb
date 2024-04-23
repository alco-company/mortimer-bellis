class DateColumn < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  attr_accessor :field

  def initialize(field:, css: nil)
    @field = field
    @class = css || "truncate"
  end

  def view_template
    field.blank? ? 
      div { "&nbsp;".html_safe } :
      div( class: @class ) { format_date field}
  end

  def format_date(date)
    date.strftime("%d/%m/%Y")
  end
end
