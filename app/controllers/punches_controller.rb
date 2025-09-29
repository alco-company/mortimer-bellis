class PunchesController < MortimerController
  #
  # From /dashboards/show
  # <ActionController::Parameters {
  # "punch"=>#<ActionController::Parameters {"punch_clock_id"=>"50"} permitted: true>,
  # "authenticity_token"=>"dMXypk0HuC_LRwXOX714C8ySPS9H3ScthVJ6mm-6nDdAC8jf2Kw4pH7-GtOT9cXETd77_Ch9T4YaHbXOghu2ew",
  # "controller"=>"punches",
  # "action"=>"create"
  # } permitted: true>
  #
  # From /punches/new
  # Parameters: {
  #   "authenticity_token"=>"[FILTERED]",
  #   "punch"=>
  #     "user_id"=>"1",
  #     "punch_clock_id"=>"5",
  #     "punched_at"=>"2024-09-26T07:15",
  #     "state"=>"out",
  #     "comment"=>""},
  #     "commit"=>"Opret"
  # }
  def create
    punch_clock = PunchClock.find(resource_params[:punch_clock_id]) rescue PunchClock.where(tenant: Current.tenant).first
    # from dashboard?
    if resource_params[:punched_at].blank?
      @resource = Current.user.punch(punch_clock, resource_params[:state], request.remote_ip)
      flash[:success] = t(".post")
      @activity_list = Current.user.tenant.punches.order(punched_at: :desc).take(10)
      Broadcasters::Resource.new(@resource, { controller: "punches" }, target: "activity_list").create
      Broadcasters::Resource.new(@resource, params.permit!).create
      render turbo_stream: [
        turbo_stream.replace("punch_button", partial: "punches/punch_button", locals: { user: Current.user, punch_clock: punch_clock }, alert: I18n.t("punch.create.failed")),
        turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }) # ,
        # turbo_stream.replace("activity_list", partial: "punches/dashboard_punches", locals: { activity_list: @activity_list, user: Current.user })
      ]
      flash.clear
    else
      user = User.find(resource_params[:user_id])
      respond_to do |format|
        if @resource = user.punch(punch_clock, resource_params[:state], request.remote_ip)
          Broadcasters::Resource.new(@resource, { controller: "punches" }, target: "activity_list").create
          Broadcasters::Resource.new(@resource, params.permit!).create
          flash[:success] = t(".post")
          format.turbo_stream {
            render turbo_stream: [ turbo_stream.update("form", ""), turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }) ]
            flash.clear
          }
          format.html { redirect_to resources_url, success: t(".post") }
          format.json { render :show, status: :created, location: @resource }
        else
          format.html { render :new, status: :unprocessable_entity, warning: t(".warning") }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(punch: [ :tenant_id, :user_id, :punch_clock_id, :punched_at, :state, :remote_ip, :comment ])
    end

    #
    # implement on the controller inheriting this concern
    def create_callback
      begin
        PunchCard.recalculate user: @resource.user, across_midnight: false, date: @resource.punched_at.to_date
      rescue => e
        say e
      end
    end
    def update_callback
      begin
        PunchCard.recalculate user: @resource.user, across_midnight: false, date: @resource.punched_at.to_date
      rescue => e
         say e
      end
    end

    #
    # implement on the controller inheriting this concern
    # in order to not having to extend the update method on this concern
    #
    # this has to return a method that will be called after the destroy!!
    # ie - it cannot call methods on the object istself!
    #
    def destroy_callback
      "PunchCard.recalculate( user: User.find(#{@resource.user.id}), across_midnight: false, date: '#{@resource.punched_at.to_date}')"
    end
end
