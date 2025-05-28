class FiltersController < MortimerController
  # include Authentication
  # defined in the batch_actions concern
  # before_action :set_batch, only: %i[ index destroy]
  # before_action :set_resource_class
  # before_action :set_resources_stream

  def new
    @filter_form = params[:filter_form]
    @resource = @filter = Filter.by_user().by_view(params[:filter_form]).take || Filter.new
    @url = params[:url]
    @filter.filter ||= {}
  end

  def edit
    @filter_form = params[:filter_form]
    @resource = @filter = Filter.find(params[:id])
    @url = @filter_form == "filters" ? resources_url : params[:url]
    @filter.filter ||= {}
  end

  def index
    @pagy, @records = pagy(Filter.by_tenant())
  end

  # Parameters: {"authenticity_token"=>"[FILTERED]",
  #   "filter"=>{"filter_form"=>"punch_cards", "tenant_id"=>"1", "name"=>"max", "work_date"=>"16/4/24", "work_minutes"=>"1t 20m", "break_minutes"=>"", "submit"=>""}}
  #
  def create
    json_filters = build_json_filters
    Filter.create(name: filter_params[:name], tenant: Current.tenant, user: Current.user, view: filter_params[:filter_form], filter: json_filters)
    redirect_to redirect_url
  end

  def update
    json_filters = params[:filter].except(:filter_form, :url, :tenant_id, :submit)
    filter = Filter.by_user.by_view(filter_params[:filter_form]).take

    filter.update(tenant: Current.tenant, view: filter_params[:filter_form], filter: json_filters) if filter
    redirect_to redirect_url
  end

  def destroy
    Filter.find(params[:id]).destroy
    redirect_to redirect_url, status: 303, notice: I18n.t("filters.destroyed")
  end

  private

    def build_json_filters
      filter_params.except(:filter_form, :filter_preset, :name, :url, :tenant_id, :submit)
    end

    def redirect_url
      fp = filter_params[:url].split("?").first
      "#{fp}?replace=true"
    end

    #
    # request: #<ActionDispatch::Request:0x0000000108c4f5a0>,
    #   params: {"authenticity_token"=>"[FILTERED]",
    #     "filter"=>{"url"=>"https://localhost:3000/teams", "filter_form"=>"teams", "tenant_id"=>"1", "name"=>"", "team_color"=>"", "locale"=>"en", "time_zone"=>"", "submit"=>""},
    #     "controller"=>"filters", "action"=>"create"} }
    def filter_params
      # params.expect(filter: [ :url, :filter_form, :filter_preset, :tenant_id, :name, date: [], field: [], scope: [] ])
      params.expect(:filter).permit!
    end

    def create_params
      params.expect(filter: [ :form, :preset ]) # , filter_formrequire(filter).permit!
    end

  # def set_resources_stream
  #   tenant = Current.tenant || @resource&.tenant || nil
  #   @resources_stream ||= tenant.nil? ?
  #     "1_#{resource_class.to_s.underscore.pluralize}" :
  #     "%s_%s" % [ tenant&.id, resource_class.to_s.underscore.pluralize ]
  # end

  # def resource_class
  #   @resource_class ||= set_resource_class
  # end

  # def set_resource_class
  #   ctrl = params.dig(:controller).split("/").last
  #   case ctrl
  #   # when "invitations"; UserInvitation
  #   when "notifications"; Noticed::Notification
  #   when "applications"; Oauth::Application
  #   else; ctrl.classify.constantize
  #   end
  # rescue => e
  #   redirect_to "/", alert: I18n.t("errors.resources.resource_class.not_found", ctrl: params.dig(:controller), reason: e.to_s) and return
  # end
end
