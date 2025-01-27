class FilterFieldsController < ApplicationController
  def new
    @filter = Filter.new
    m = params[:model]
    f = params[:field]
    v = params[:value] || ""
    selector =  [ [ "==", "eq" ], [ "!=", "neq" ], [ "<", "lt" ], [ ">", "gt" ], [ "=~", "like" ], [ "!~", "not_like" ] ]
    s = selector.filter { |s| s[1] == params[:selected] }
    render turbo_stream: turbo_stream.replace("li_#{m}_#{f}",
      partial: "filter_fields/new",
      locals: { filter: @filter, selector: selector, model: m, field: f, value: v, selected: s[0] })
  end

  def show
    @model, @field = params[:field].split("-")
    @value = params[:value]
    @selected = params[:selected]
  end
end
