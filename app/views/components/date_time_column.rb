class DateTimeColumn < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  attr_accessor :field

  def initialize(field:, css: nil)
    @field = field
    @class = css || "truncate"
  end

  def view_template
    field.blank? ?
      div { "&nbsp;".html_safe } :
      div(class: @class) { format_datetime field }
  end

  def format_datetime(datetime)
    datetime.strftime("%d/%m/%Y %H:%M:%S")
  end
end