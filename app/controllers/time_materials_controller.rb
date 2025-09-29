class TimeMaterialsController < MortimerController
  def new
    super
    resource.initialize_new get_hourly_rate, get_default_time_material_date
  end

  def index
    @resources = resources
      # if ActiveModel::Type::Boolean.new.cast(params[:show_all])
      #   @resources = @resources.order(wdate: :desc)
      # elsif params[:search].blank? && params[:s].blank? && params[:d].blank? && !(@filter.persisted? rescue false)
      #   my_open = @resources.where(user_id: Current.user.id).not_done_or_pushed
      #   @resources = (my_open.exists? ? my_open : @resources).order(wdate: :desc)
      # else
      @resources = @resources.order(wdate: :desc)
    # end
    super
  end

  def show
    process_state_toggle or super
  end

  def edit
    resource.customer_name =  resource.customer&.name || resource.customer_name  # unless resource.customer_id.blank?
    resource.project_name =   resource.project&.name  || resource.project_name   # unless resource.project_id.blank?
    resource.product_name =   resource.product&.name  || resource.product_name   # unless resource.product_id.blank?
    super
    preprocess_time
  end

  # pick up the play button from the time_material#index view
  #
  def create
    # set_mileage
    create_play
    super
  end

  # POST /users/:id/archive
  # roadmapped for future use iaw sales
  #
  # def archive
  #   resource = TimeMaterial.find(params[:id])
  #   if resource
  #     resource.archived? ?
  #       (resource.pushed_to_erp! && notice = t("time_material.unarchived")) :
  #       (resource.archived! && notice = t("time_material.archived"))
  #     redirect_back(fallback_location: root_path, notice: notice)
  #     Broadcasters::Resource.new(resource, { controller: "time_materials" }).replace
  #   else
  #     redirect_back(fallback_location: root_path, warning: t("users.not_found"))
  #   end
  # end

  private

    def process_state_toggle
      process_reload or process_pause_resume
    end

    def process_reload
      return false unless params.dig(:reload).present?
      reload_time_spent
      Current.get_tenant.users.each do |u|
        Broadcasters::Resource.new(resource, { controller: "time_materials" }, user: u, stream: "#{u.id}_time_materials").replace if resource.active?
      end
      # Broadcasters::Resource.new(resource, { controller: "time_materials" }).replace if resource.active?
      # Broadcasters::Resource.new(resource.reload,
      #   { controller: "time_materials" },
      #   Current.user).replace if resource.active?

      head :ok
      true
    end

    def process_pause_resume
      return false unless params.dig(:pause).present?

      if params.dig(:pause) == "stop"
        stop
      else
        pause_resume
      end
    end

    def before_create_callback
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
      postprocess_time
      true
    end

    def before_update_callback
      r = resource.prepare_tm resource_params
      return false if r == false
      resource_params(r)
      true
    end

    def update_callback
      postprocess_time
      true
    end

    # called before showing the edit form
    # fix hour_time, minute_time, registered_minutes, started_at, time_spent
    # user can edit from an active or paused, other state
    # after hitting the 'edit' context_menu button
    # or after hitting the 'stop' button
    #
    def preprocess_time
      set_time
      resource_params[:hour_time] = resource.hour_time
      resource_params[:minute_time] = resource.minute_time
      # ht, mt = resource.time.split(":")
      # resource_params[:registered_minutes] = ht.to_i * 60 + mt.to_i
      # resource_params[:started_at] = resource.started_at
      # resource_params[:time_spent] = resource.time_spent
    end

    # called after create or update of a time_material
    # hour_time, minute_time, registered_minutes, started_at, time_spent should be set straight
    #
    def postprocess_time
      return unless resource.is_time?
      ht, mt = resource.time.split(":").map(&:to_i).each_with_index { |v, i| i==0 ? v : v.clamp(0, 59) }
      resource.registered_minutes = ht * 60 + mt
      resource.minutes_reloaded_at = Time.current
      resource.save
    end

    #
    # if the time_material is active, recalculate time_spent from started_at
    # if paused, keep time_spent as is
    # if stopped or done, keep time_spent as is
    def reload_time_spent
      if resource.active?
        minutes = resource.add_elapsed_to_registered!
        resource.hour_time, resource.minute_time = (minutes).divmod(60)
        resource.save
        # resource.update time_spent: resource.elapsed_seconds_now, registered_minutes: minutes, paused_at: nil, minutes_reloaded_at: Time.current
      end
    end

    def set_play_time
      # return unless Current.get_user.should? :fill_play_time_in_time_fields
      # rmin = resource.registered_minutes || 0
      # ts = resource.time_spent || 0
      # ht, mt = (rmin + ts).divmod(3600)
      # mt, _sec = mt.divmod(60)
      # ht, mt = resource.sanitize_time(ht, mt).split(":")
      # resource.hour_time = ht
      # resource.minute_time = mt
    end

    def create_play
      return unless params[:play].present?

      # ht, mt = resource.sanitize_time("0", "0").split(":")

      params[:time_material] = {
        time: "0",
        state: 1,
        user_id: Current.user.id,
        started_at: Time.current,
        paused_at: nil,
        time_spent: 0,
        hour_time: 0,
        minute_time: 0,
        hour_rate: get_hourly_rate,
        registered_minutes: 0,
        date: get_default_time_material_date,
        about: Current.user.default(:default_time_material_about, "")
      }
      params.delete(:play)
      params[:played] = true
    end

    def pause_resume
      if resource.user == Current.user or Current.user.admin? or Current.user.superadmin?
        params.dig(:pause) == "pause" ?
          resource.pause_time_spent && flash.now[:success] = t("time_material.paused") :
          resource.resume_time_spent && flash.now[:success] = t("time_material.resumed")
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

    # Only allow a list of trusted parameters through.
    def resource_params(rp = nil)
      return params unless params[:time_material].present?

      # set params if rp
      if rp
        params[:time_material] = rp
      end
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
        :is_separate,
        :tag_list,
        :task_comment,
        :location_comment
      ])
    end

    def stop
      @_action_name = "edit"

      resource.pause_time_spent(true) && flash.now[:success] = t("time_material.stopped")
      set_time

      Broadcasters::Resource.new(resource, params).replace

      respond_to do |format|
        format.html { stream_it_all }
        format.turbo_stream { stream_it_all }
      end
    end

    def set_time
      total_minutes = (resource.registered_minutes || 0)
      ht, mt = total_minutes.divmod(60)
      if Current.user.should?(:limit_time_to_quarters)
        mt = case mt
        when 0; ht==0 ? 15 : 0
        when 1..15; 15
        when 16..30; 30
        when 31..45; 45
        else; ht += 1; 0
        end
      end

      if Current.get_user.should? :fill_play_time_in_time_fields
        resource.hour_time = ht
        resource.minute_time = mt
        resource.registered_minutes = ht * 60 + mt
        resource.minutes_reloaded_at = Time.current
      end
      resource.save
    end

    def stream_it_all
      render turbo_stream: [
        turbo_stream.replace("flash_container", partial: "application/flash_message", locals: { tenant: Current.get_tenant, messages: flash, user: Current.get_user }),
        turbo_stream.replace("form", partial: "application/edit", locals: { resource: resource, tenant: Current.get_tenant, messages: flash, user: Current.get_user })
      ]
    end

    def get_default_time_material_date
      dt=Current.get_user.default(:default_time_material_date, "Time.current.to_date")
      if dt =~ /.to_date/
        parts = dt.split(".")
        eval(parts.join(".")).class == Date ? eval(parts.join(".")) : eval(default_date)
      else
        raise "no date expected"
      end
    rescue
      eval(default_date)
    end

    def get_hourly_rate
      return Current.get_user.hourly_rate if Current.get_user.hourly_rate != 0
      Current.get_tenant.time_products.first.base_amount_value || Current.get_user.default(:default_time_material_rate, 0)
    end
end
