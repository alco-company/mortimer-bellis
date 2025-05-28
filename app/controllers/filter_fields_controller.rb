class FilterFieldsController < ApplicationController
  def new
    @filter = Filter.new
    model = params[:model].classify.constantize
    _m = model.new
    @model = model
    @field = params[:field]
    @value = params[:value] || ""
    select_field
    # selector = Filter::SELECTORS
    # @selected = selector.filter { |s| s[1] == params[:selected] }
    # @selected, @selected_text = @selected.first
  rescue
    UserMailer.error_report(e.to_s, "FilterFieldsController#new - failed with params: #{params}").deliver_later
  end

  def show
    @filter = Filter.new
    @model, @field = params[:field].split("-")
    @value = params[:value]
    select_field
    # @selected = params[:selected]
    # @selected_text = Filter::SELECTORS.filter { |s| s[1] == params[:selected] }.first[0] rescue ""
  end

  def select_field
    selector = Filter::SELECTORS
    @selected = selector.filter { |s| s[1] == params[:selected] }
    @selected_text, @selected = @selected.first rescue [ "", "" ]
  end
end
