class DateColumn < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  attr_accessor :field

  def initialize(field:, css: nil, &block)
    @field = field
    @class = css || "truncate"
  end

  def view_template(&)
    field.blank? ?
      div { "&nbsp;".html_safe } :
      div(class: @class) do
         plain format_date(field)
         yield if block_given?
      end
  end

  def format_date(date)
    date.strftime("%d/%m/%Y")
  end
end
