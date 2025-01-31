class FilterFieldsController < ApplicationController
  def new
    @filter = Filter.new
    @model = params[:model].classify.constantize
    @field = params[:field]
    @value = params[:value] || ""
    selector = Filter::SELECTORS
    @selected = selector.filter { |s| s[1] == params[:selected] }
    # render turbo_stream: turbo_stream.replace("li_#{m}_#{f}",
    #   partial: "filter_fields/new",
    #   locals: { filter: @filter, selector: selector, model: m, field: f, value: v, selected: s[0] })
  end

  def show
    @model, @field = params[:field].split("-")
    @value = params[:value]
    @selected = params[:selected]
    @selected_text = Filter::SELECTORS.filter { |s| s[1] == params[:selected] }.first[0] rescue ""
  end
end
