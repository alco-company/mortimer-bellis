class DateTimeColumn < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  attr_accessor :field

  def initialize(field:, seconds: false, css: nil)
    @field = field
    @seconds = seconds
    @class = css || "truncate"
  end

  def view_template
    field.blank? ?
      div { "&nbsp;".html_safe } :
      div(class: @class) { format_datetime field }
  end

  def format_datetime(datetime)
    @seconds ?
      datetime.strftime("%d/%m/%Y %H:%M:%S") :
      datetime.strftime("%d/%m/%Y %H:%M")
  end
end
