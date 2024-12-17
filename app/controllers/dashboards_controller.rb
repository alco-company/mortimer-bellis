class DashboardsController < MortimerController
  before_action :set_dashboard, only: %i[ show ]

  # before_action :set_dashboard, only: %i[ show edit update destroy ]

  # # GET /dashboards or /dashboards.json
  # def index
  #   @dashboards = Dashboard.all
  # end

  # # GET /dashboards/show_dashboard or /dashboards/show_dashboard.json
  # def show_dashboard
  def show
    @activity_list = Current.user.tenant.punches.order(punched_at: :desc).take(10)
    @punch_clock = PunchClock.where(tenant: Current.user.tenant).first rescue nil
  end

  # # GET /dashboards/new
  # def new
  #   @dashboard = Dashboard.new
  # end

  # # GET /dashboards/1/edit
  # def edit
  # end

  # # POST /dashboards or /dashboards.json
  # def create
  #   @dashboard = Dashboard.new(dashboard_params)

  #   respond_to do |format|
  #     if @dashboard.save
  #       format.html { redirect_to dashboard_url(@dashboard), notice: "Dashboard was successfully created." }
  #       format.json { render :show, status: :created, location: @dashboard }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @dashboard.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /dashboards/1 or /dashboards/1.json
  # def update
  #   respond_to do |format|
  #     if @dashboard.update(dashboard_params)
  #       format.html { redirect_to dashboard_url(@dashboard), notice: "Dashboard was successfully updated." }
  #       format.json { render :show, status: :ok, location: @dashboard }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @dashboard.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /dashboards/1 or /dashboards/1.json
  # def destroy
  #   @dashboard.destroy!

  #   respond_to do |format|
  #     format.html { redirect_to dashboards_url, notice: "Dashboard was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dashboard
      @dashboard = Dashboard.find_by(tenant: Current.tenant)
      unless @dashboard
        @dashboard = Dashboard.create(tenant: Current.tenant, feed: "https://www.dr.dk/nyheder/service/feeds/penge")
      end
      # get_feed if @dashboard
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(dashboard: [ :tenant_id, :feed, :last_feed, :last_feed_at ])
    end

    def get_feed
      return if @dashboard.last_feed && @dashboard.last_feed_at > 4.hour.ago
      # feed = Feedjira::Feed.fetch_and_parse(dashboard.feed)
      # feed.entries.first.summary
      require "rss"
      require "open-uri"
      rss = URI.open(@dashboard.feed)
      if rss
        @dashboard.update(last_feed_at: Time.now, last_feed: File.read(rss))
      end
    end
end
