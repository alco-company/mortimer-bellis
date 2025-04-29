class TimeMaterialsController < MortimerController
  def new
    super
    resource.customer_name = TimeMaterial.by_exact_user(Current.user).last&.customer_name
    resource.state =         Current.user.default(:default_time_material_state, "draft")
    resource.about =         Current.user.default(:default_time_material_about, "")
    resource.hour_time =     Current.user.default(:default_time_material_hour_time, "")
    resource.minute_time =   Current.user.default(:default_time_material_minute_time, "")
    resource.rate =          Current.user.default(:default_time_material_rate, "")
    resource.over_time =     Current.user.default(:default_time_material_over_time, 0)
    resource.date =          get_default_time_material_date "Time.current.to_date"
    resource.user_id =       Current.user.id
  end

  def index
    # tell user about his uncompleted tasks
    # Current.user.notify(action: :tasks_remaining, title: t("tasks.remaining.title"), msg: t("tasks.remaining.msg", count: Current.user.tasks.first_tasks.uncompleted.count)) unless Current.user.notified?(:tasks_remaining)
    @resources = resources.order(wdate: :desc)
    super
  end

  def show
    if params.dig(:reload).present? and resource.active?
      resource.time_spent ||= 0
      resource.started_at ||= Time.current
      time_spent = (Time.current.to_i - resource.started_at.to_i) + resource.time_spent
      resource.update time_spent: time_spent, paused_at: nil, started_at: Time.current
      Broadcasters::Resource.new(resource.reload, { controller: "time_materials" }, Current.user).replace
      head :ok
    else
      params.dig(:pause).present? ? pause_resume : super
    end
  end

  def edit
    resource.update time_spent: resource.time_spent + (Time.current.to_i - resource.started_at.to_i) if resource.active? # or resource.paused?
    # resource.update time: resource.sanitize_time_spent
    resource.customer_name = resource.customer&.name  || resource.customer_name  # unless resource.customer_id.blank?
    resource.project_name = resource.project&.name    || resource.project_name   # unless resource.project_id.blank?
    resource.product_name = resource.product&.name    || resource.product_name   # unless resource.product_id.blank?
  end

  # pick up the play button from the time_material#index view
  #
  def create
    # set_mileage
    create_play
    super
  end

  # POST /users/:id/archive
  def archive
    resource = TimeMaterial.find(params[:id])
    if resource
      resource.archived? ?
        (resource.pushed_to_erp! && notice = t("time_material.unarchived")) :
        (resource.archived! && notice = t("time_material.archived"))
      redirect_back(fallback_location: root_path, notice: notice)
      Broadcasters::Resource.new(resource, { controller: "time_materials" }).replace
    else
      redirect_back(fallback_location: root_path, warning: t("users.not_found"))
    end
  end

  private

    def before_create_callback
      active_time_material
      r = resource.prepare_tm resource_params
      return false if r == false
      resource_params(r)
      true
    end

    def resource_create
      resource.customer_id = resource_params[:customer_id]
      resource.project_id = resource_params[:project_id]
      resource.save
    end

    def create_callback
      set_time
    end

    def before_update_callback
      active_time_material
      r = resource.prepare_tm resource_params
      return false if r == false
      resource_params(r)
      true
    end

    def update_callback
      set_time
    end

    def active_time_material
      if resource.active?
        resource.time_spent ||= 0
        resource.started_at ||= Time.current
        time_spent = (Time.current.to_i - resource.started_at.to_i) + resource.time_spent
        resource.update time_spent: time_spent, paused_at: nil, started_at: Time.current
      end
    end

    def set_time
      return true if resource_params[:product_name].present? or resource_params[:product_id].present?
      if resource_params[:state].present? && resource_params[:state] == "done" # done!
        ht = resource_params[:hour_time] # && resource.hour_time=0
        mt = resource_params[:minute_time] # && resource.minute_time=0
        resource.update time: resource.sanitize_time(ht, mt) unless ht.blank? || mt.blank?
      end
      true
    end

    def create_play
      return unless params[:play].present?

      params[:time_material] = {
        time: "0",
        state: 1,
        user_id: Current.user.id,
        started_at: Time.current,
        time_spent: 0,
        date: get_default_time_material_date("Time.current.to_date.yesterday"),
        about: Current.user.default(:default_time_material_about, "")
      }
      params.delete(:play)
      params[:played] = true
    end

    def pause_resume
      if resource.user == Current.user or Current.user.admin? or Current.user.superadmin?
        params.dig(:pause) == "pause" ? pause : resume
        Broadcasters::Resource.new(resource, params).replace
        respond_to do |format|
          format.html { render turbo_stream: [ turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }) ] }
          format.turbo_stream { render turbo_stream: [ turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }) ] }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: [
            flash.now[:warning] = t("time_material.not_your_time_material"),
            turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user })
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

    # Only allow a list of trusted parameters through.
    def resource_params(rp = nil)
      return params unless params[:time_material].present?

      # set params if rp
      if rp
        params[:time_material] = rp
      end
      #
      # TODO make odo work
      #
      # if params.require(:time_material)[:odo_from_time].present? &&
      #    params.require(:time_material)[:odo_to_time].present? &&
      #    params.require(:time_material)[:odo_from].present? &&
      #    params.require(:time_material)[:odo_to].present? &&
      #    params.require(:time_material)[:kilometers].present?
      #    params[:time_material][:about] = I18n.t("time_material.type.mileage")
      # end
      params.expect(time_material: [
        :tenant_id,
        :date,
        :hour_time,
        :minute_time,
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
        # :odo_from,
        # :odo_to,
        # :kilometers,
        # :trip_purpose,
        # :odo_from_time,
        # :odo_to_time,
        :is_invoice,
        :is_free,
        :is_offer,
        :is_separate
      ])
    end

    def pause
      resource.time_spent ||= 0
      resource.started_at ||= Time.current
      time_spent = (Time.current.to_i - resource.started_at.to_i) + resource.time_spent
      paused_at = Time.current
      resource.update state: 2, time_spent: time_spent, paused_at: paused_at
      flash.now[:success] = t("time_material.paused")
    end

    def resume
      resource.update state: 1, started_at: Time.current, paused_at: nil
      flash.now[:success] = t("time_material.resumed")
    end

    def get_default_time_material_date(default_date)
      dt=Current.get_user.default(:default_time_material_date, default_date)
      if dt =~ /.to_date/
        parts = dt.split(".")
        eval(parts.join(".")).class == Date ? eval(parts.join(".")) : eval(default_date)
      else
        raise "no date expected"
      end
    rescue
      eval(default_date)
    end
end
