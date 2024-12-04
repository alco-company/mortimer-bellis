class TimeMaterialsController < MortimerController
  def new
    super
    @resource.customer_name = TimeMaterial.by_exact_user(Current.user).last&.customer_name
    @resource.state = 3
    @resource.date = Time.current.to_date
    @resource.user_id = Current.user.id
  end

  def show
    params.permit![:pause].present? ? pause_resume : super
  end

  def edit
    @resource.update time_spent: @resource.time_spent + (Time.current.to_i - @resource.started_at.to_i) if @resource.active? # or @resource.paused?
    @resource.update time: limit_time_spent_to_quarters(@resource.time_spent, true)
    @resource.customer_name = @resource.customer&.name unless @resource.customer_id.blank?
    @resource.project_name = @resource.project&.name unless @resource.project_id.blank?
    @resource.product_name = @resource.product&.name unless @resource.product_id.blank?
  end

  # pick up the play button from the time_material#index view
  #
  def create
    # set_mileage
    create_play if params[:play].present?
    return unless prepare_tm
    super
  end

  def update
    # set_mileage
    return unless prepare_tm
    super
  end

  # POST /users/:id/archive
  def archive
    @resource = TimeMaterial.find(params[:id])
    if @resource
      @resource.archived? ?
        (@resource.pushed_to_erp! && notice = t("time_material.unarchived")) :
        (@resource.archived! && notice = t("time_material.archived"))
      redirect_back(fallback_location: root_path, notice: notice)
      Broadcasters::Resource.new(@resource).replace
    else
      redirect_back(fallback_location: root_path, warning: t("users.not_found"))
    end
  end

  private

    def create_play
      params[:time_material] = {
        time: "0,25",
        state: 1,
        user_id: Current.user.id,
        started_at: Time.current,
        time_spent: 0,
        date: Time.current.to_date,
        about: t("time_material.current_task")
      }
      params.delete(:play)
      params[:played] = true
    end

    def pause_resume
      if @resource.user == Current.user or Current.user.admin? or Current.user.superadmin?
        params.permit![:pause] == "pause" ? pause : resume
        Broadcasters::Resource.new(@resource, params).replace
        respond_to do |format|
          format.html { render turbo_stream: [ turbo_stream.replace("flash_container", partial: "application/flash_message") ] }
          format.turbo_stream { render turbo_stream: [ turbo_stream.replace("flash_container", partial: "application/flash_message") ] }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: [
            flash.now[:warning] = t("time_material.not_your_time_material"),
            turbo_stream.replace("flash_container", partial: "application/flash_message")
          ] }
        end
      end
    end

    # def set_mileage
    #   return unless params[:time_material].present?
    #   if resource_params[:odo_from_time].present? &&
    #      resource_params[:odo_to_time].present? &&
    #      resource_params[:odo_from].present? &&
    #      resource_params[:odo_to].present? &&
    #      resource_params[:kilometers].present?
    #      params[:time_material][:about] = I18n.t("time_material.type.mileage")
    #   end
    # end

    def limit_time_spent_to_quarters(time, minutes = false)
      return if time.to_s.include?(":")
      unless resource.should?(:limit_time_to_quarters)  # NOTICE!! calls resourceable#resource
        return time
      else
        time = split_time(time, minutes)
        time[1] = "15" if time[1].to_i < 15
        time[1] = "30" if time[1].to_i > 15 && time[1].to_i < 30
        time[1] = "45" if time[1].to_i > 30 && time[1].to_i < 45
        time[1] = "0" && time[0] = time[0].to_i + 1 if time[1].to_i > 45
      end
      time.join(":")
    end

    def split_time(time, minutes)
      if minutes
        d, h, m, _s = @resource.calc_hrs_minutes(time)
        time = d * 24 * 60 + h * 60 + m
        time = time.divmod 60
      else
        time = resource_params[:time].split(",") if resource_params[:time].present? && resource_params[:time].include?(",")
        time = resource_params[:time].split(".") if resource_params[:time].present? && resource_params[:time].include?(".")
      end
      time
    end

    def prepare_tm
      if resource_params[:state].present? && resource_params[:state] == "3" # done!
        resource_params[:time] = limit_time_spent_to_quarters(resource_params[:time])
        r = TimeMaterial.build(resource_params)
        if params[:played].present? or (r.valid? and r.values_ready_for_push?)
          params.delete(:played)
          return true
        end
        flash.now[:warning] = t(".validation_errors")
        render turbo_stream: [
          turbo_stream.update("form", partial: "new", locals: { resource: r }),
          turbo_stream.replace("flash_container", partial: "application/flash_message")
        ]
        return false
      end
      true
    rescue => e
      false
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      return params unless params[:time_material].present?

      if params.require(:time_material)[:odo_from_time].present? &&
         params.require(:time_material)[:odo_to_time].present? &&
         params.require(:time_material)[:odo_from].present? &&
         params.require(:time_material)[:odo_to].present? &&
         params.require(:time_material)[:kilometers].present?
         params[:time_material][:about] = I18n.t("time_material.type.mileage")
      end
      params.expect(time_material: [
        :tenant_id,
        :date,
        :time,
        :over_time,
        :about,
        :user_id,
        :customer_name,
        :customer_id,
        :project_name,
        :project_id,
        :product_name,
        :product_id,
        :quantity,
        :rate,
        :unit_price,
        :unit,
        :discount,
        :comment,
        :state,
        :time_spent,
        :started_at,
        :paused_at,
        :is_invoice,
        :is_free,
        :is_offer,
        :is_separate,
        :odo_from,
        :odo_to,
        :kilometers,
        :trip_purpose,
        :odo_from_time,
        :odo_to_time
      ])
    end

    def pause
      time_spent = @resource.time_spent + (Time.current.to_i - @resource.started_at.to_i)
      paused_at = Time.current
      @resource.update state: 2, time_spent: time_spent, paused_at: paused_at
      flash.now[:success] = t("time_material.paused")
    end

    def resume
      @resource.update state: 1, started_at: Time.current, paused_at: nil
      flash.now[:success] = t("time_material.resumed")
    end
end
