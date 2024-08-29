class Column < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo

  attr_accessor :value, :field

  def initialize(value: false, table: false, field: false, sort: false, css: nil, &block)
    @value = value
    @table = table
    @sort = sort        # params, like { controller: "employees", s: "name", d: "asc" }
    @field = field
    @class = css || "truncate"
  end

  def view_template(&block)
    @table ? table_value(&block) : div_value(&block)
  end

  def table_value(&block)
    @table == :head ? th_value(&block) : td_value(&block)
  end

  def th_value(&block)
    th(class: @class) do
      plain value
      yield if block_given?
    end
  end

  def td_value(&block)
    td(class: @class) do
      plain value
      yield if block_given?
    end
  end

  def div_value(&block)
    value.blank? ?
      div { "&nbsp;".html_safe } :
      div(class: @class) do
        if block_given?
          yield value
        else
          @sort ? build_link(value) : plain(value)
        end
      end
  end

  def build_link(val)
    arrow = field.to_s == @sort[:s] ? "mort-active-arrow" : "mort-passive-arrow"
    if direction == "asc"
      link_to(sort_url) do
        plain(val)
        span(class: arrow) { "▲" }
      end
    else
      link_to(sort_url) do
        plain(val)
        span(class: arrow) { "▼" }
      end
    end
  end

  def sort_url
    helpers.url_for(controller: @sort[:controller], action: :index, s: field, d: direction)
  rescue
    "#"
  end

  def direction
    @sort[:s] == field.to_s ? (@sort[:d] == "asc" ? "desc" : "asc") : "asc"
  end
end
