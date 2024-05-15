class DateColumn < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  attr_accessor :field

  def initialize(field:, css: nil, table: false, &block)
    @field = field
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
      plain format_date(field)
      yield if block_given?
    end
  end

  def td_field
    td(class: @class) do
      plain format_date(field)
      yield if block_given?
    end
  end

  def div_field
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
