class FiltersController < BaseController
  include Authentication

  def new
    @filter_form = params[:filter_form]
    @resource = @filter = Filter.by_tenant().where(view: params[:filter_form]).take || Filter.new
    @url = params[:url]
    @filter.filter ||= {}
  end

  def index
    @pagy, @records = pagy(Filter.by_tenant())
  end

  # Parameters: {"authenticity_token"=>"[FILTERED]",
  #   "filter"=>{"filter_form"=>"punch_cards", "tenant_id"=>"1", "name"=>"max", "work_date"=>"16/4/24", "work_minutes"=>"1t 20m", "break_minutes"=>"", "submit"=>""}}
  #
  def create
    json_filters = filter_params.except(:filter_form, :filter_preset, :url, :tenant_id, :submit)
    Filter.create(tenant: Current.tenant, view: filter_params[:filter_form], filter: json_filters)
    redirect_to redirect_url
  end

  def update
    json_filters = params[:filter].except(:filter_form, :url, :tenant_id, :submit)
    filter = Filter.by_tenant().where(view: filter_params[:filter_form]).take

    filter.update(tenant: Current.tenant, view: filter_params[:filter_form], filter: json_filters)
    redirect_to redirect_url
  end

  def destroy
    Filter.find(params[:id]).destroy
    redirect_to redirect_url, status: 303, notice: "Filter was successfully destroyed."
  end

  def redirect_url
    filter_params[:url].split("?").first
  end

  #
  # request: #<ActionDispatch::Request:0x0000000108c4f5a0>,
  #   params: {"authenticity_token"=>"[FILTERED]",
  #     "filter"=>{"url"=>"https://localhost:3000/teams", "filter_form"=>"teams", "tenant_id"=>"1", "name"=>"", "team_color"=>"", "locale"=>"en", "time_zone"=>"", "submit"=>""},
  #     "controller"=>"filters", "action"=>"create"} }
  def filter_params
    params.expect(filter: [ :url, :filter_form, :filter_preset, :tenant_id, :name ])
  end

  def create_params
    params.expect(filter: [ :form, :preset ]) # , filter_formrequire(filter).permit!
  end
end
