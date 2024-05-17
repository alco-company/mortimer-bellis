class BooleanColumn < Phlex::HTML
  include Phlex::Rails::Helpers::Routes

  attr_accessor :field

  def initialize(field:, table: false, css: nil, &block)
    @field = field
    @table = table
    @class = css || "truncate"
  end

  def view_template(&block)
    @table ? table_field(&block) : div_field(&block)
  end

  def table_field(&block)
    @table == :head ? th_field(&block) : td_field(&block)
  end

  def th_field(&block)
    th(class: @class) do
      plain true_false(field)
      yield if block_given?
    end
  end

  def td_field(&block)
    td(class: @class) do
      plain true_false(field)
      yield if block_given?
    end
  end

  def div_field
    field.blank? ?
      div { "&nbsp;".html_safe } :
      div(class: @class) do
         plain true_false(field)
         yield if block_given?
      end
  end

  def true_false(value)
    value ? I18n.t("yes") : I18n.t("no")
  end
end
