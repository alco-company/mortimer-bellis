class FiltersController < ApplicationController
  def new
    @filter_form = params[:filter_form]
    @filter = Filter.where(view: params[:filter_form]).take || Filter.new
    @url = params[:url]
    @filter.filter ||= {}
  end

  def index
    @pagy, @records = pagy(Filter.all)
  end

  # Parameters: {"authenticity_token"=>"[FILTERED]",
  #   "filter"=>{"filter_form"=>"punch_cards", "account_id"=>"1", "name"=>"max", "work_date"=>"16/4/24", "work_minutes"=>"1t 20m", "break_minutes"=>"", "submit"=>""}}
  #
  def create
    json_filters = params[:filter].except(:filter_form, :url, :account_id, :submit)

    Filter.create(account: Current.account, view: params[:filter][:filter_form], filter: json_filters)
    redirect_to params.permit![:filter][:url]
  end

  def update
    json_filters = params[:filter].except(:filter_form, :url, :account_id, :submit)
    filter = Filter.where(view: params[:filter][:filter_form]).take

    filter.update(account_id: params[:filter][:account_id], view: params[:filter][:filter_form], filter: json_filters)
    redirect_to params.permit![:filter][:url]
  end

  def destroy
    Filter.find(params[:id]).destroy
    redirect_to params.permit![:filter][:url]
  end
end
