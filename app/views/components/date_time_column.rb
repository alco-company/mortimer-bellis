class DateTimeColumn < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  attr_accessor :field

  def initialize(field:, seconds: false, css: nil, table: false, &block)
    @field = field
    @seconds = seconds
    @table = table
    @class = css || "truncate"
  end

  def view_template(&)
    @table ? table_field : div_field
  end

  def table_field
    @table == :head ? th_field : td_field
  end

  def th_field
    th(class: @class) do
      plain format_datetime(field)
      yield if block_given?
    end
  end

  def td_field
    td(class: @class) do
      plain format_datetime(field)
      yield if block_given?
    end
  end

  def div_field
    field.blank? ?
      div { "&nbsp;".html_safe } :
      div(class: @class) do
         plain format_datetime(field)
         yield if block_given?
      end
  end

  def format_datetime(datetime)
    @seconds ?
      datetime.strftime("%d/%m/%Y %H:%M:%S") :
      datetime.strftime("%d/%m/%Y %H:%M")
  end
end
